import boto3
import os

def lambda_handler(event, context):
    src_bucket = os.environ["BUCKET"]
    dest_bucket = os.environ["BUCKET"]
    dest_prefix = os.environ["DEST_PREFIX"]

    key = event["Key"]

    s3 = boto3.client("s3")
    dest_key = dest_prefix + key.split("/")[-1]
    s3.copy_object(
        Bucket=dest_bucket,
        CopySource={"Bucket": src_bucket, "Key": key},
        Key=dest_key
    )
    return {"CopiedKey": dest_key}