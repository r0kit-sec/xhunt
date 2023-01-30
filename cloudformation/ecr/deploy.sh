#!/bin/bash

ECR_REPOS=ecr-repos

xhunt-cloudformation-$ECR_REPOS-create() {
    aws cloudformation create-stack --stack-name $ECR_REPOS \
        --template-body file://$1
}

xhunt-cloudformation-$ECR_REPOS-update() {
    aws cloudformation update-stack --stack-name $ECR_REPOS \
        --template-body file://$1
}

xhunt-cloudformation-$ECR_REPOS-delete() {
    aws cloudformation delete-stack --stack-name $ECR_REPOS
}