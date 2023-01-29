import boto3
import logging
import os
from botocore.exceptions import ClientError


def get_queue(sqs, name):
    """
    Gets an SQS queue by name.

    :param name: The name that was used to create the queue.
    :return: A Queue object.
    """
    try:
        queue = sqs.get_queue_by_name(QueueName=name)
        logging.info("Got queue '%s' with URL=%s", name, queue.url)
    except ClientError as error:
        logging.exception("Couldn't get queue named %s.", name)
        raise error
    else:
        return queue


def receive_messages(queue, max_number, wait_time):
    """
    Receive a batch of messages in a single request from an SQS queue.

    :param queue: The queue from which to receive messages.
    :param max_number: The maximum number of messages to receive. The actual number
                       of messages received might be less.
    :param wait_time: The maximum time to wait (in seconds) before returning. When
                      this number is greater than zero, long polling is used. This
                      can result in reduced costs and fewer false empty responses.
    :return: The list of Message objects received. These each contain the body
             of the message and metadata and custom attributes.
    """
    try:
        messages = queue.receive_messages(
            MessageAttributeNames=['All'],
            MaxNumberOfMessages=max_number,
            WaitTimeSeconds=wait_time
        )
        for msg in messages:
            logging.info("Received message: %s: %s", msg.message_id, msg.body)
    except ClientError as error:
        logging.exception("Couldn't receive messages from queue: %s", queue)
        raise error
    else:
        return messages


def map_to_receipt_entries(messages):
    return [{'Id': m.message_id, 'ReceiptHandle': m.receipt_handle} for m in messages]


def cleanup_messages(queue, messages):
    receipt_entries = map_to_receipt_entries(messages)
    logging.info("Deleting messages...")
    response = queue.delete_messages(Entries=receipt_entries)
    logging.info(response)


def fetch_queue_parameter():
    queue_name = os.environ["REFLECTED_XSS_QUEUE_SSM_PARAMETER"]
    ssm = boto3.client('ssm')
    response = ssm.get_parameter(Name=queue_name, WithDecryption=False)
    result = response['Parameter']['Value'].split('/')[-1]
    logging.info(response)
    return result


def delete_message(queue, message):
    try:
        logging.info("Deleting message...")
        response = queue.delete_messages(Entries=[{'Id': message.message_id, 'ReceiptHandle': message.receipt_handle}])
        logging.info(response)
    except ClientError as error:
        logging.exception(f"Failed to delete message with id {message.message_id}: {error}")


def submit_jobs(client, queue, messages):
    # Jobs are submitted in batches to optimize and distribute workload in the cluster
    for message in messages:
        try:
            response = client.submit_job(
                jobName=f'dalfox-{message.message_id}',
                jobQueue='test-job-queue',
                jobDefinition='test-job-definition',
                parameters={},
            )
            logging.info(f"Submitted job: {response['jobName']}")
            delete_message(queue, message)
        except ClientError as error:
            logging.exception(f"Failed to submit job for message id {message.message_id}: {error}")


def lambda_handler(event, context):
    logger = logging.getLogger()
    if 'DEBUG' in os.environ and os.environ['DEBUG']:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info(os.environ)
    logger.info('## EVENT')
    logger.info(event)

    messages = event['Records']
    logger.info(f"Got messages: {messages}")
    # submit_jobs(batch, queue, messages)