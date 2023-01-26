xhunt-cloudformation-ecr-create() {
    aws cloudformation create-stack --stack-name $1 \
        --template-body file://$2 \
        --parameter file://$3 \
        --region $AWS_REGION
}

xhunt-cloudformation-ecr-destroy() {
    aws cloudformation delete-stack --stack-name $1 \
        --region $AWS_REGION
}
