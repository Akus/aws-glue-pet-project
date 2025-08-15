import boto3
import os

def lambda_handler(event, context):
    bucket = os.environ["BUCKET"]
    prefix = os.environ["PREFIX"]

    s3 = boto3.client("s3")
    paginator = s3.get_paginator("list_objects_v2")
    latest_obj = None

    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            if not latest_obj or obj["LastModified"] > latest_obj["LastModified"]:
                latest_obj = obj

    if not latest_obj:
        raise Exception("No files found!")

    return {"Key": latest_obj["Key"]}