## Overview

xhunt is an independent AWS-based automation platform for running repeatable, asynchronous workflows as containerized batch jobs. While it originated from security automation and continuous recon use cases, the core focus is platform engineering: orchestrating jobs, isolating execution, handling failures, and keeping the system observable and cost-aware.

The system is built around:
- AWS Batch for job scheduling and execution
- Fargate (FARGATE_SPOT) as the compute backend for Batch jobs
- AWS SAM / CloudFormation for provisioning serverless dispatchers and shared infrastructure
- An ECR-hosted tools container image that runs the actual workload commands

## Architecture at a glance

- DynamoDB (SubdomainUrls table with Streams enabled) acts as an event source for new work
- Lambda dispatchers (Python) submit AWS Batch jobs in response to events
- SQS queues decouple stages of work and distribute URLs/tasks across job types
- AWS Batch JobDefinitions run the tools container image with command overrides (shell scripts under `./tasks/`)
- CloudWatch Logs capture per-job output via `awslogs` configuration on the Batch JobDefinitions

## What this demonstrates

- Designing an event-driven workflow that triggers batch execution from real event sources (DynamoDB Streams, SQS)
- Submitting AWS Batch jobs programmatically from Lambda using `submit_job` with container command overrides
- Running containerized batch workloads on AWS Batch backed by Fargate Spot
- Building a reusable "tools" container image (Dockerfile) that packages common automation tooling
- Decoupling workflow stages with SQS queues and DLQs for better reliability
- Durable storage patterns using DynamoDB (including conditional writes to avoid overwriting existing items)
- Operational basics: structured logging from dispatchers, job logs in CloudWatch, and timeouts/retry settings in JobDefinitions
- Infrastructure provisioning via AWS SAM / CloudFormation (nested serverless applications under `cloudformation/sam/`)

## Key components in this repo

- `cloudformation/sam/xhunt-serverless/template.yaml`
  - Shared infrastructure: DynamoDB table, SQS queues, ECR repo, AWS Batch compute environment + job queue, IAM roles
  - Nested SAM apps for individual dispatchers and job definitions
- `cloudformation/sam/xhunt-serverless/*_job_dispatcher/`
  - Python Lambda functions that accept events (SQS or DynamoDB Streams) and submit AWS Batch jobs
- `tasks/`
  - Shell entrypoints invoked by Batch jobs via container command overrides (examples: `gau_urls.sh`, `dalfox_single_url.sh`, `arjun_single_url.sh`)
- `Dockerfile`
  - Builds the `xhunt-tools` container image with a set of CLI tools installed and task scripts bundled
- `build-deploy.sh`
  - Builds and pushes the tools image to ECR (`xhunt-tools:latest`)

## Notes

This repository is shared as a representative example of platform-oriented system design applied to batch automation workloads. It is not intended to be a polished or production-ready service. The emphasis is on architectural tradeoffs, event-driven job orchestration, and practical considerations when running asynchronous containerized workloads on AWS Batch (Fargate backend).
