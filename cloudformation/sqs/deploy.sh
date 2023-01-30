#!/bin/bash

xhunt-cloudformation-reflected-xss-queue-create() {
    aws cloudformation create-stack --stack-name $1 \
        --template-body file://$2 \
        --region $AWS_REGION
        #--parameter file://$4 \
}

xhunt-cloudformation-reflected-xss-queue-update() {
    aws cloudformation update-stack --stack-name $1 \
        --template-body file://$2 \
        --region $AWS_REGION
        #--parameter file://$4 \
}

xhunt-cloudformation-reflected-xss-queue-delete() {
    aws cloudformation delete-stack --stack-name $1 \
        --region $AWS_REGION
}
