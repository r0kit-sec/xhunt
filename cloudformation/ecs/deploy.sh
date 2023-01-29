#!/bin/bash

ECS_FARGATE_TASK_CLUSTER=ecs-fargate-task-cluster

xhunt-cloudformation-$ECS_FARGATE_TASK_CLUSTER-create() {
    aws cloudformation create-stack --stack-name $ECS_FARGATE_TASK_CLUSTER \
        --template-body file://$1 \
        --parameters file://$2 \
        --capabilities CAPABILITY_NAMED_IAM
}

xhunt-cloudformation-$ECS_FARGATE_TASK_CLUSTER-update() {
    aws cloudformation update-stack --stack-name $ECS_FARGATE_TASK_CLUSTER \
        --template-body file://$1 \
        --parameters file://$2 \
        --capabilities CAPABILITY_NAMED_IAM
}

xhunt-cloudformation-$ECS_FARGATE_TASK_CLUSTER-delete() {
    aws cloudformation delete-stack --stack-name $ECS_FARGATE_TASK_CLUSTER
}
