xhunt-cloudformation-ecr-create() {
    aws cloudformation create-stack --stack-name ecr-repos \
        --template-body file://ecr.yaml \
        --region $AWS_REGION
}

xhunt-cloudformation-ecr-destroy() {
    aws cloudformation delete-stack --stack-name ecr-repos \
        --region $AWS_REGION
}
