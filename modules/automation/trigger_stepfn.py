import os
import boto3
import json

def lambda_handler(event, context):
    sfn = boto3.client('stepfunctions')
    sfn_arn = os.environ['STATE_MACHINE_ARN']
    # Optionally pass the S3 event as input
    sfn.start_execution(
        stateMachineArn=sfn_arn,
        input=json.dumps(event)
    )
    return {"status": "Step Function started"}