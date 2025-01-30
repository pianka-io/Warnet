import asyncio
import boto3
import logging
import random
import time
import discord

GUILD_ID = 1332524138681598104
CHANNEL_ID = 1333535069117353984

logger = logging.getLogger()
logger.setLevel(logging.INFO)

REGION_NAMES = {
    "us-east-2": "Ohio, USA (NORAM)",
    "us-east-1": "Virginia, USA (NORAM)",
    "us-west-1": "California, USA (NORAM)",
    "us-west-2": "Oregon, USA (NORAM)",
    "mx-central-1": "Querétaro, Mexico (NORAM)",
    "ca-central-1": "Montreal, Canada (NORAM)",
    "ca-west-1": "Calgary, Canada (NORAM)",
}
DNS_ZONE_ID = "Z08087823H6YLIRFX7JR5"
DNS_RECORD_NAME = "war.pianka.io"
SECURITY_GROUP_NAME = "ec2"


async def send_message(message_content):
    intents = discord.Intents.default()
    intents.message_content = True
    client = discord.Client(intents=intents)

    @client.event
    async def on_ready():
        try:
            guild = discord.utils.get(client.guilds, id=GUILD_ID)
            if not guild:
                logger.error(f"Guild with ID {GUILD_ID} not found.")
                await client.close()
                return

            channel = discord.utils.get(guild.channels, id=CHANNEL_ID)
            if not channel:
                logger.error(f"Channel with ID {CHANNEL_ID} not found.")
                await client.close()
                return

            await channel.send(message_content)
            logger.info(f"Message sent to channel {CHANNEL_ID}: {message_content}")
        except Exception as e:
            logger.error(f"Error sending message: {str(e)}")
        finally:
            await client.close()

    await client.start(get_discord_token())


def lambda_handler(event, context):
    route53_client = boto3.client("route53")

    try:
        last_used_region = get_last_used_region()
        available_regions = [r for r in REGION_NAMES.keys() if r != last_used_region]
        random_region = random.choice(available_regions)
        set_last_used_region(random_region)

        if random_region == "us-east-2":
            random_subnet = "subnet-022414a9295e7f1e1"
        else:
            random_subnet = get_vpc_subnet(random_region)
            logger.info(f"Fetched VPC Subnet ID for region {random_region}: {random_subnet}")

        ami_id = get_latest_warnet_ami(random_region)
        logger.info(f"Fetched latest 'warnet' AMI ID for region {random_region}: {ami_id}")
        instance_type = "t3.xlarge" if random_region in ["mx-central-1", "ca-west-1", "ca-central-1"] else "t2.xlarge"

        logger.info(
            f"Selected region: {random_region}, subnet: {random_subnet}, AMI: {ami_id}, Instance Type: {instance_type}")

        ec2_client = boto3.client("ec2", region_name=random_region)
        security_groups = ec2_client.describe_security_groups(
            Filters=[{"Name": "group-name", "Values": [SECURITY_GROUP_NAME]}]
        )
        if not security_groups["SecurityGroups"]:
            raise Exception(f"Security group '{SECURITY_GROUP_NAME}' not found in region {random_region}")
        security_group_id = security_groups["SecurityGroups"][0]["GroupId"]

        logger.info(f"Launching new instance in region {random_region}.")
        new_instance = ec2_client.run_instances(
            ImageId=ami_id,
            InstanceType=instance_type,
            KeyName="warnet",
            MaxCount=1,
            MinCount=1,
            NetworkInterfaces=[
                {
                    "AssociatePublicIpAddress": True,
                    "SubnetId": random_subnet,
                    "DeviceIndex": 0,
                    "Groups": [security_group_id]
                }
            ]
        )
        new_instance_id = new_instance["Instances"][0]["InstanceId"]

        logger.info(f"Waiting for instance {new_instance_id} to be running.")
        wait_for_instance_running(ec2_client, new_instance_id)

        logger.info(f"Describing new instance {new_instance_id}.")
        new_instance_description = ec2_client.describe_instances(InstanceIds=[new_instance_id])
        new_instance_ip = new_instance_description["Reservations"][0]["Instances"][0]["PublicIpAddress"]

        logger.info(f"Updating DNS record to point to {new_instance_ip}.")
        route53_client.change_resource_record_sets(
            HostedZoneId=DNS_ZONE_ID,
            ChangeBatch={
                "Comment": "Update to new EC2 instance",
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": DNS_RECORD_NAME,
                            "Type": "A",
                            "TTL": 15,
                            "ResourceRecords": [{"Value": new_instance_ip}],
                        },
                    }
                ],
            },
        )
        logger.info(f"DNS successfully updated to {new_instance_ip}.")

        logger.info("Terminating old instances in all regions.")
        for region in REGION_NAMES.keys():
            ec2_client = boto3.client("ec2", region_name=region)
            instances = ec2_client.describe_instances(
                Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
            )
            logger.info(f"Found instances in region {region}: {instances}")
            for reservation in instances["Reservations"]:
                for instance in reservation["Instances"]:
                    instance_id = instance["InstanceId"]
                    if instance_id != new_instance_id:
                        try:
                            logger.info(f"Terminating instance {instance_id} in region {region}")
                            ec2_client.terminate_instances(InstanceIds=[instance_id])
                            logger.info(f"Instance {instance_id} termination initiated.")
                        except ec2_client.exceptions.ClientError as e:
                            if "InvalidInstanceID.NotFound" in str(e):
                                logger.warning(f"Instance {instance_id} not found. It might already be terminated.")
                            else:
                                raise

        message = f"Warnet server moved to **{REGION_NAMES[random_region]}** at **{new_instance_ip}**"
        asyncio.run(send_message(message))

    except Exception as e:
        logger.error(f"Error: {str(e)}")

    return {
        "statusCode": 200,
        "body": "Operation completed."
    }


def get_discord_token():
    secrets_client = boto3.client("secretsmanager")
    secret_name = "discord_token_ugh"
    response = secrets_client.get_secret_value(SecretId=secret_name)
    if "SecretString" not in response:
        raise Exception(f"Secret {secret_name} does not contain a string value.")
    return response["SecretString"]


def get_latest_warnet_ami(region_name):
    ec2_client = boto3.client("ec2", region_name=region_name)
    response = ec2_client.describe_images(
        Owners=["self"],
        Filters=[
            {"Name": "name", "Values": ["warnet"]},
            {"Name": "state", "Values": ["available"]}
        ]
    )
    images = response["Images"]
    if not images:
        raise Exception(f"No AMIs found with name 'warnet' in region {region_name}")
    latest_image = max(images, key=lambda img: img["CreationDate"])
    return latest_image["ImageId"]


def get_vpc_subnet(region_name):
    ec2_client = boto3.client("ec2", region_name=region_name)
    response = ec2_client.describe_subnets(
        Filters=[
            {"Name": "tag:Name", "Values": ["*-subnet"]},
            {"Name": "vpc-id", "Values": [get_vpc_id(region_name)]}
        ]
    )
    subnets = response["Subnets"]
    if not subnets:
        raise Exception(f"No subnets with tag 'Name' ending in '-subnet' found in region {region_name}.")
    return subnets[0]["SubnetId"]


def get_vpc_id(region_name):
    ec2_client = boto3.client("ec2", region_name=region_name)
    response = ec2_client.describe_vpcs(
        Filters=[
            {"Name": "is-default", "Values": ["false"]}
        ]
    )
    vpcs = response["Vpcs"]
    if not vpcs:
        raise Exception(f"No non-default VPC found in region {region_name}.")
    return vpcs[0]["VpcId"]


def wait_for_instance_running(ec2_client, instance_id):
    for _ in range(30):
        try:
            response = ec2_client.describe_instances(InstanceIds=[instance_id])
            state = response["Reservations"][0]["Instances"][0]["State"]["Name"]
            if state == "running":
                return True
        except ec2_client.exceptions.ClientError as e:
            if "InvalidInstanceID.NotFound" in str(e):
                logger.warning(f"Instance {instance_id} not found during wait.")
        time.sleep(10)
    raise Exception(f"Instance {instance_id} did not reach 'running' state within timeout.")


def get_last_used_region():
    ssm_client = boto3.client("ssm")
    try:
        response = ssm_client.get_parameter(Name="last_used_region")
        return response["Parameter"]["Value"]
    except ssm_client.exceptions.ParameterNotFound:
        return None


def set_last_used_region(region):
    ssm_client = boto3.client("ssm")
    ssm_client.put_parameter(
        Name="last_used_region",
        Value=region,
        Type="String",
        Overwrite=True
    )
