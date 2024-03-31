NGINX demo app on AWS ECS
=====
This will use Terraform to setup an NGINX demo application on AWS ECS using AWS Fargate which is a serverless compute to run containers.

## Pre-requisites
### Preparing AWS credential
1. For simplicity and quick testing in an AWS environment, generate temporary AWS secret and access key, this is not recommended in production enviroment.
2. Export the AWS credentials as environment variables.
```
export AWS_ACCESS_KEY_ID="AWSXXXXXX0978"
export AWS_SECRET_ACCESS_KEY="AULP0XXXXXXY7US9XXXXOP56JX"
```

### Setup Terraform backend
1. Create a Dynamo DB table for storing Terraform state lock, this is recommended in real world application.
```
aws dynamodb create-table --table-name terraform-test \
--attribute-definitions AttributeName=LockID,AttributeType=S \
--key-schema AttributeName=LockID,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```
2. Create a AWS S3 bucket for storing Terraform states via CLI
```
aws s3api create-bucket --bucket tllang-test --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1
```
3. Use [tfenv](https://github.com/tfutils/tfenv) to manage different Terraform version, the Terraform version is defined at `.terraform-version`

### Setup and access the NGINX demo application
1. Redirect to `terraform/ecs-nginx` directory, perform the following Terraform commands, type in `yes` to confirm `terraform apply` to setup the NGINX application.
```
terraform init
terraform plan
terraform apply
```
2. Then, access the NGINX application via the `load_balancer_endpoint` generated from the Terraform output in a web browser like Google Chrome.
```
http://nginx-lb-1234567890.ap-southeast-1.elb.amazonaws.com/
```

### Clean up
1. Destroy all the resources via `terraform destroy` command.
2. Delete the s3 bucket, Dynamo DB table if no longer in use.