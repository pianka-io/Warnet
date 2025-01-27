import boto3
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    ec2_client = boto3.client('ec2')

    try:
        instances = ec2_client.describe_instances()

        first_instance_id = None
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                first_instance_id = instance['InstanceId']
                break
            if first_instance_id:
                break

        if first_instance_id:
            ec2_client.reboot_instances(InstanceIds=[first_instance_id])
            result = f"Successfully rebooted instance: {first_instance_id}"
        else:
            result = "No EC2 instances found."

    except Exception as e:
        result = f"Error: {str(e)}"

    return {
        "statusCode": 200,
        "body": result
    }



# import boto3
# import logging
# import random
#
# logger = logging.getLogger()
# logger.setLevel(logging.INFO)
#
# AMI_ID = "ami-0cc9ac965c1eace1e"
# VPC_SUBNETS = {
#     "us-east-1": ["subnet-051e5ef4e1e3fe5bf"],  # Virginia
#     "us-west-1": ["subnet-05e54382eb6b4ae70"],  # California
# }
# DNS_ZONE_ID = "Z08087823H6YLIRFX7JR5"
# DNS_RECORD_NAME = "war.pianka.io"
# SECURITY_GROUP_NAME = "ec2"  # Security group to assign
#
# def lambda_handler(event, context):
#     # ec2_client = boto3.client('ec2')
#     # route53_client = boto3.client('route53')
#     #
#     # try:
#     #     # Get the currently running instance
#     #     instances = ec2_client.describe_instances(
#     #         Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
#     #     )
#     #
#     #     current_instance_id = None
#     #     for reservation in instances['Reservations']:
#     #         for instance in reservation['Instances']:
#     #             current_instance_id = instance['InstanceId']
#     #             break
#     #         if current_instance_id:
#     #             break
#     #
#     #     # Stop the current instance if found
#     #     if current_instance_id:
#     #         ec2_client.stop_instances(InstanceIds=[current_instance_id])
#     #         logger.info(f"Stopped current instance: {current_instance_id}")
#     #
#     #     # Select a random VPC and subnet
#     #     random_region = random.choice(list(VPC_SUBNETS.keys()))
#     #     random_subnet = random.choice(VPC_SUBNETS[random_region])
#     #     logger.info(f"Selected region: {random_region}, subnet: {random_subnet}")
#     #
#     #     # Update the client to use the selected region
#     #     ec2_client = boto3.client('ec2', region_name=random_region)
#     #
#     #     # Find the security group ID by name
#     #     security_groups = ec2_client.describe_security_groups(
#     #         Filters=[{"Name": "group-name", "Values": [SECURITY_GROUP_NAME]}]
#     #     )
#     #     if not security_groups['SecurityGroups']:
#     #         raise Exception(f"Security group '{SECURITY_GROUP_NAME}' not found in region {random_region}")
#     #     security_group_id = security_groups['SecurityGroups'][0]['GroupId']
#     #     logger.info(f"Using security group: {SECURITY_GROUP_NAME} (ID: {security_group_id})")
#     #
#     #     # Launch a new EC2 instance
#     #     new_instance = ec2_client.run_instances(
#     #         ImageId=AMI_ID,
#     #         InstanceType="t2.micro",  # Adjust as needed
#     #         MaxCount=1,
#     #         MinCount=1,
#     #         SubnetId=random_subnet,
#     #         SecurityGroupIds=[security_group_id],
#     #     )
#     #     new_instance_id = new_instance['Instances'][0]['InstanceId']
#     #     logger.info(f"Launched new instance: {new_instance_id}")
#     #
#     #     # Wait for the new instance to become running
#     #     waiter = ec2_client.get_waiter('instance_running')
#     #     waiter.wait(InstanceIds=[new_instance_id])
#     #     logger.info(f"New instance is running: {new_instance_id}")
#     #
#     #     # Get the public IP of the new instance
#     #     new_instance_description = ec2_client.describe_instances(InstanceIds=[new_instance_id])
#     #     new_instance_ip = new_instance_description['Reservations'][0]['Instances'][0]['PublicIpAddress']
#     #     logger.info(f"New instance public IP: {new_instance_ip}")
#     #
#     #     # Update the DNS record to point to the new instance
#     #     route53_client.change_resource_record_sets(
#     #         HostedZoneId=DNS_ZONE_ID,
#     #         ChangeBatch={
#     #             "Comment": "Update to new EC2 instance",
#     #             "Changes": [
#     #                 {
#     #                     "Action": "UPSERT",
#     #                     "ResourceRecordSet": {
#     #                         "Name": DNS_RECORD_NAME,
#     #                         "Type": "A",
#     #                         "TTL": 15,
#     #                         "ResourceRecords": [{"Value": new_instance_ip}],
#     #                     },
#     #                 }
#     #             ],
#     #         },
#     #     )
#     #     logger.info(f"DNS record updated to point to {new_instance_ip}")
#     #     result = f"Successfully moved instance to region {random_region} with new IP {new_instance_ip}"
#     #
#     # except Exception as e:
#     #     logger.error(f"Error: {str(e)}")
#     #     result = f"Error: {str(e)}"
#
#     return {
#         "statusCode": 200,
#         "body": result
#     }
