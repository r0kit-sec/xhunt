#!/bin/bash

CONTAINER_NAME=$1

xhunt-build-push-container() {
    # CONTAINER_NAME=xhunt
    CONTAINER_TAG=latest

    # TODO Fix CI/CD and rename this to xhunt-tools
    ECR_REPO_NAME=xhunt-ecr-repo
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    docker tag $CONTAINER_NAME:$CONTAINER_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
}

xhunt-build-push-container
