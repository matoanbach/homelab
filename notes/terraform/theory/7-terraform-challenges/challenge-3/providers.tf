terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
    for_each = var.instance_config
    ami = each.value.ami
    instance_type = each.value.instance_type
}