terraform {
  required_version = ">= 1.3.6"
  backend "s3" {
    region         = "ap-southeast-1"
    bucket         = "tllang-test"
    dynamodb_table = "terraform-test"
    key            = "ecs/nginx.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }

    local = {
      version = "2.1.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
