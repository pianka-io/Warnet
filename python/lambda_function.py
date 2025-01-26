import boto3


def lambda_handler(event, context):
    result = "warnet"
    return {
        "statusCode": 200,
        "body": result
    }
