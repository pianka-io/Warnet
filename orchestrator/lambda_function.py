import asyncio
import boto3
import logging
import random
import time
import requests
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
    "sa-east-1": "São Paulo, Brazil (LATAM)",
    "eu-central-1": "Frankfurt, Germany (EMEA)",
    "eu-west-1": "Dublin, Ireland (EMEA)",
    "eu-west-2": "London, UK (EMEA)",
    "eu-south-1": "Milan, Italy (EMEA)",
    "eu-west-3": "Paris, France (EMEA)",
    "eu-south-2": "Aragón, Spain (EMEA)",
    "eu-north-1": "Stockholm, Sweden (EMEA)",
    "eu-central-2": "Zürich, Switzerland (EMEA)",
    "me-south-1": "Manama, Bahrain (EMEA)",
    "me-central-1": "United Arab Emirates (EMEA)",
    "il-central-1": "Tel Aviv, Israel (EMEA)",
    "af-south-1": "Cape Town, South Africa (EMEA)"
}
DNS_ZONE_ID = "Z08087823H6YLIRFX7JR5"
DNS_RECORD_NAME = "war.pianka.io"
SECURITY_GROUP_NAME = "ec2"


def lambda_handler(event, context):
    route53_client = boto3.client("route53")

    try:
        last_used_region = get_last_used_region()
        random_region = choose_weighted_region(exclude_region=last_used_region)
        set_last_used_region(random_region)

        ami_id = get_latest_warnet_ami(random_region)
        instance_type = "t3.xlarge" if random_region in [
            "mx-central-1",
            "ca-west-1",
            "ca-central-1",
            "eu-south-1",
            "eu-south-2",
            "eu-north-1",
            "eu-central-2",
            "me-south-1",
            "me-central-1",
            "il-central-1",
            "af-south-1"
        ] else "t2.xlarge"

        ec2_client = boto3.client("ec2", region_name=random_region)
        security_groups = ec2_client.describe_security_groups(
            Filters=[{"Name": "group-name", "Values": [SECURITY_GROUP_NAME]}]
        )
        if not security_groups["SecurityGroups"]:
            raise Exception(f"Security group '{SECURITY_GROUP_NAME}' not found in region {random_region}")
        security_group_id = security_groups["SecurityGroups"][0]["GroupId"]

        new_instance = ec2_client.run_instances(
            ImageId=ami_id,
            InstanceType=instance_type,
            # KeyName="filip",
            KeyName="warnet",
            MaxCount=1,
            MinCount=1,
            IamInstanceProfile={
                "Name": "certbot-instance-profile"
            },
            NetworkInterfaces=[
                {
                    "AssociatePublicIpAddress": True,
                    "SubnetId": get_vpc_subnet(random_region),
                    "DeviceIndex": 0,
                    "Groups": [security_group_id]
                }
            ]
        )
        new_instance_id = new_instance["Instances"][0]["InstanceId"]

        wait_for_instance_running(ec2_client, new_instance_id)

        new_instance_description = ec2_client.describe_instances(InstanceIds=[new_instance_id])
        new_instance_ip = new_instance_description["Reservations"][0]["Instances"][0]["PublicIpAddress"]

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

        for region in REGION_NAMES.keys():
            ec2_client = boto3.client("ec2", region_name=region)
            instances = ec2_client.describe_instances(
                Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
            )
            for reservation in instances["Reservations"]:
                for instance in reservation["Instances"]:
                    instance_id = instance["InstanceId"]
                    if instance_id != new_instance_id:
                        try:
                            ec2_client.terminate_instances(InstanceIds=[instance_id])
                        except ec2_client.exceptions.ClientError as e:
                            if "InvalidInstanceID.NotFound" in str(e):
                                continue
                            else:
                                raise

        location = REGION_NAMES[random_region]
        lat, lon = get_location_coordinates(location)
        map_url = get_map_url(lat, lon)
        message = f"Server moved to **{location}** at **{new_instance_ip}**"

        asyncio.run(send_message(message, map_url))

    except Exception as e:
        logger.error(f"Error: {str(e)}")

    return {
        "statusCode": 200,
        "body": "Operation completed."
    }


async def send_message(message_content, image_url):
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

            embed = discord.Embed(description=message_content)
            embed.set_image(url=image_url)

            await channel.send(embed=embed)
            logger.info(f"Message sent to channel {CHANNEL_ID}: {message_content}")
        except Exception as e:
            logger.error(f"Error sending message: {str(e)}")
        finally:
            await client.close()

    await client.start(get_secret("discord_token_ugh"))


def choose_weighted_region(exclude_region=None):
    weighted_regions = {
        "us-east-2": 3, "us-east-1": 3, "us-west-1": 3, "us-west-2": 3, "mx-central-1": 3, "ca-central-1": 3, "ca-west-1": 3,
        "sa-east-1": 2, "eu-central-1": 2, "eu-west-1": 2, "eu-west-2": 2, "eu-south-1": 2, "eu-west-3": 2, "eu-south-2": 2,
        "eu-north-1": 2, "eu-central-2": 2,
        "me-south-1": 1, "me-central-1": 1, "il-central-1": 1, "af-south-1": 1,
        # Placeholder for future expansion
        "ap-southeast-1": 0.5, "ap-northeast-1": 0.5
    }

    # Exclude last used region
    if exclude_region and exclude_region in weighted_regions:
        del weighted_regions[exclude_region]

    regions, weights = zip(*weighted_regions.items())
    return random.choices(regions, weights=weights, k=1)[0]


def get_secret(secret_name):
    secrets_client = boto3.client("secretsmanager")
    response = secrets_client.get_secret_value(SecretId=secret_name)
    if "SecretString" not in response:
        raise Exception(f"Secret {secret_name} does not contain a string value.")
    return response["SecretString"]


def get_location_coordinates(location):
    api_key = get_secret("locationiq_api_key_ugh")
    location = location.split("(")[0].strip()
    url = f"https://us1.locationiq.com/v1/search?key={api_key}&q={location}&format=json"
    response = requests.get(url)
    if response.status_code == 200 and response.json():
        data = response.json()[0]
        return data["lat"], data["lon"]
    else:
        raise Exception(f"Failed to geocode location: {location}")


def get_map_url(lat, lon):
    api_key = get_secret("locationiq_api_key_ugh")
    return f"https://maps.locationiq.com/v3/staticmap?key={api_key}&center={lat},{lon}&zoom=3&size=640x386&markers={lat},{lon}|icon:small-red-cutout"


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
    if region_name == "us-east-2":
        return "subnet-022414a9295e7f1e1"
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
