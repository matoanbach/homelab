provider "aws" {
    # version    = "~> 2.54"
  region = "us-east-1"
}

provider "digitalocean" {}

terraform {
  # required_version = "1.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.54"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


resource "aws_eip" "kplabs_app_ip" {
  # domain = "vpc"
}
