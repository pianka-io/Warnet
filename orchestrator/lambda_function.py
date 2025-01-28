import asyncio
import boto3
import logging
import random
import time
import discord

DISCORD_TOKEN = ""
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
    "ca-central-1": "Montreal, Canda (NORAM)",
    "ca-west-1": "Calgary, Canda (NORAM)",
}
AMI_IDS = {
    "us-east-2": "ami-0e8a33c8bd2dd610e",
    "us-east-1": "ami-01d12c3cc435df8d6",
    "us-west-1": "ami-081517d6e3f515146",
    "us-west-2": "ami-08b3b54fa76ba6bf9",
    "mx-central-1": "ami-030ee8f6c98599c98",
    "ca-central-1": "ami-08bf2733f31b36630",
    "ca-west-1": "ami-04214dc711bd39f6e"
}
VPC_SUBNETS = {
    "us-east-2": ["subnet-022414a9295e7f1e1"],
    "us-east-1": ["subnet-0ef99798b819667a9"],
    "us-west-1": ["subnet-011e3970d07d7bb98"],
    "us-west-2": ["subnet-05f0675562abf386d"],
    "mx-central-1": ["subnet-0b1699ad9806d9b4e"],
    "ca-central-1": ["subnet-005a726eb1f0d273f"],
    "ca-west-1": ["subnet-0138252b6002e3f1c"]
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

    await client.start(DISCORD_TOKEN)


def lambda_handler(event, context):
    route53_client = boto3.client('route53')

    try:
        # Select a random region and instance type
        random_region = random.choice(list(VPC_SUBNETS.keys()))
        random_subnet = random.choice(VPC_SUBNETS[random_region])
        ami_id = AMI_IDS[random_region]
        instance_type = "t3.xlarge" if random_region in ["mx-central-1", "ca-west-1"] else "t2.xlarge"

        logger.info(
            f"Selected region: {random_region}, subnet: {random_subnet}, AMI: {ami_id}, Instance Type: {instance_type}")

        ec2_client = boto3.client('ec2', region_name=random_region)
        security_groups = ec2_client.describe_security_groups(
            Filters=[{"Name": "group-name", "Values": [SECURITY_GROUP_NAME]}]
        )
        if not security_groups['SecurityGroups']:
            raise Exception(f"Security group '{SECURITY_GROUP_NAME}' not found in region {random_region}")
        security_group_id = security_groups['SecurityGroups'][0]['GroupId']

        logger.info(f"Launching new instance in region {random_region}.")
        new_instance = ec2_client.run_instances(
            ImageId=ami_id,
            InstanceType=instance_type,
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
        new_instance_id = new_instance['Instances'][0]['InstanceId']

        logger.info(f"Waiting for instance {new_instance_id} to be running.")
        wait_for_instance_running(ec2_client, new_instance_id)

        logger.info(f"Describing new instance {new_instance_id}.")
        new_instance_description = ec2_client.describe_instances(InstanceIds=[new_instance_id])
        new_instance_ip = new_instance_description['Reservations'][0]['Instances'][0]['PublicIpAddress']

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
        for region in VPC_SUBNETS.keys():
            ec2_client = boto3.client('ec2', region_name=region)
            instances = ec2_client.describe_instances(
                Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
            )
            logger.info(f"Found instances in region {region}: {instances}")
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    instance_id = instance['InstanceId']
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


def wait_for_instance_running(ec2_client, instance_id):
    for _ in range(30):
        try:
            response = ec2_client.describe_instances(InstanceIds=[instance_id])
            state = response['Reservations'][0]['Instances'][0]['State']['Name']
            if state == 'running':
                return True
        except ec2_client.exceptions.ClientError as e:
            if "InvalidInstanceID.NotFound" in str(e):
                logger.warning(f"Instance {instance_id} not found during wait.")
        time.sleep(10)
    raise Exception(f"Instance {instance_id} did not reach 'running' state within timeout.")
