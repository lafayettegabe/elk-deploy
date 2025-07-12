terraform {
  backend "s3" {
    bucket = "backend-tf-0"
    key    = "servers/elk/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "aws" {
  region = local.region
}
