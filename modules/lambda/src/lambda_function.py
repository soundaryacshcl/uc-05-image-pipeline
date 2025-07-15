import os, json, boto3
from io import BytesIO
from PIL import Image

s3  = boto3.client("s3")
sns = boto3.client("sns")

DEST_BUCKET   = os.environ["DEST_BUCKET"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def lambda_handler(event, context):
    for rec in event["Records"]:
        src_bucket = rec["s3"]["bucket"]["name"]
        key        = rec["s3"]["object"]["key"]

        img_obj = s3.get_object(Bucket=src_bucket, Key=key)
        img = Image.open(BytesIO(img_obj["Body"].read()))
        img.thumbnail((800, 800))

        buf = BytesIO(); img.save(buf, format="JPEG"); buf.seek(0)
        s3.put_object(Bucket=DEST_BUCKET, Key=f"resized/{key}", Body=buf, ContentType="image/jpeg")

    sns.publish(TopicArn=SNS_TOPIC_ARN,
                Subject="Image resized",
                Message=json.dumps(event, indent=2))