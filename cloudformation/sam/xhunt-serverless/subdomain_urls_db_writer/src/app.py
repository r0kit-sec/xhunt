import boto3
import logging
import os
import time
from boto3.dynamodb.conditions import Attr
from botocore.exceptions import ClientError


def write_subdomains_urls(messages):
    table_name = os.environ['SUBDOMAIN_URLS_TABLE_NAME']
    client = boto3.resource('dynamodb')
    table = client.Table(table_name)

    for message in messages:
        try:
            url = message['body']
            subdomain = message['body'].split('/')[2].split('?')[0]
            item = {
                'sub_domain': subdomain,
                'url': url,
                'time': round(time.time())
            }
            # Never overwrite existing data
            conditional_expression = Attr('sub_domain').not_exists() and Attr('url').not_exists()
            table.put_item(
                Item=item,
                ConditionExpression=conditional_expression
            )
        except ClientError as error:
            if error.response['Error']['Code'] == 'ConditionalCheckFailedException':
                logging.info(f'subdomain and url already exist for {url}')
                continue
            logging.exception(f"Failed to submit job for message id {message['messageId']}: {error}")


def lambda_handler(event, context):
    logger = logging.getLogger()
    if 'DEBUG' in os.environ and os.environ['DEBUG']:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
    messages = event['Records']
    logger.info(f"Got messages: {messages}")
    write_subdomains_urls(messages)