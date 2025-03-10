terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.83.1"
    }
  }
  
  backend "s3" {
    bucket         = "add-terraform-state-bucket2"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "table-jenkins-add"
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "subnet_a_ip" {
  type = string
  default = "10.0.1.0/24"
}

variable "subnet_b_ip" {
  type = string
  default = "10.0.2.0/24"
}
