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
