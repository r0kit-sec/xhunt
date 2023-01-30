import boto3
import logging
import os
import shlex
from botocore.exceptions import ClientError


def submit_jobs(messages):
    # We can only get the ARN from CloudFormation, so we need to process it here to get the name
    job_queue_arn = os.environ['TASK_CLUSTER_JOB_QUEUE_ARN']
    job_definition_arn = os.environ['TASK_CLUSTER_REFLECTED_XSS_JOB_DEFINITION_ARN']
    client = boto3.client('batch')

    # Jobs are submitted in batches to optimize and distribute workload in the cluster
    for message in messages:
        try:
            raw_command = f"dalfox url -S --found-action './notify/dalfox-notify.sh @@query@@ @@type@@' --no-color {message['body']}"
            command = shlex.split(raw_command)
            logging.info(f"Submitting command: {raw_command}")
            
            response = client.submit_job(
                jobName=f"dalfox-{message['messageId']}",
                jobQueue=job_queue_arn,
                jobDefinition=job_definition_arn,
                containerOverrides={
                    'command': command
                },
            )
            logging.info(f"Submitted job: {response['jobName']}")
        except ClientError as error:
            logging.exception(f"Failed to submit job for message id {message['messageId']}: {error}")


def lambda_handler(event, context):
    logger = logging.getLogger()
    if 'DEBUG' in os.environ and os.environ['DEBUG']:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
    messages = event['Records']
    logger.info(f"Got messages: {messages}")
    submit_jobs(messages)