#!/bin/bash

xhunt-build-deploy-xhunt-tools() {
    CONTAINER_NAME=xhunt-tools
    CONTAINER_TAG=latest

    docker build -t $CONTAINER_NAME:$CONTAINER_TAG .

    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    docker tag $CONTAINER_NAME:$CONTAINER_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$CONTAINER_NAME:latest
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$CONTAINER_NAME:latest
}

xhunt-build-deploy-xhunt-tools
