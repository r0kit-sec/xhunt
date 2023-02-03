import boto3
import logging
import os
import shlex
from botocore.exceptions import ClientError


def submit_jobs(event):
    # We can only get the ARN from CloudFormation, so we need to process it here to get the name
    job_queue_arn = os.environ['TASK_CLUSTER_JOB_QUEUE_ARN']
    job_definition_arn = os.environ['TASK_CLUSTER_GAU_SUBDOMAINS_JOB_DEFINITION_ARN']
    dalfox_queue = os.environ['DALFOX_URLS_QUEUE']
    arjun_parameter_mining_queue = os.environ['ARJUN_PARAMETER_MINING_QUEUE']
    subdomain_urls_db_writer_queue = os.environ['SUBDOMAIN_URLS_DB_WRITER_QUEUE']
    client = boto3.client('batch')

    # Jobs are submitted in batches to optimize and distribute workload in the cluster
    records = [record for record in event['Records'] if record['eventName'] == 'INSERT']
    for record in records:
        try:
            subdomain = record['dynamodb']['NewImage']['sub_domain']['S']
            event_id = record['eventID']
            raw_command = f"./tasks/gau_urls.sh {subdomain} {dalfox_queue} {arjun_parameter_mining_queue} {subdomain_urls_db_writer_queue}"
            command = shlex.split(raw_command)
            logging.info(f"Submitting command: {raw_command}")
            
            response = client.submit_job(
                jobName=f"gau-urls-{event_id}",
                jobQueue=job_queue_arn,
                jobDefinition=job_definition_arn,
                containerOverrides={
                    'command': command
                },
            )
            logging.info(f"Submitted job: {response['jobName']}")
        except ClientError as error:
            logging.exception(f"Failed to submit job for subdomain {subdomain}: {error}")


def setup_logging():
    logger = logging.getLogger()
    if 'DEBUG' in os.environ and os.environ['DEBUG']:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    setup_logging()
    submit_jobs(event)