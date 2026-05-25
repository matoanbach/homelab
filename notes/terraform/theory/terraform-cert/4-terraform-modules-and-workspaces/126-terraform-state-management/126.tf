terraform {
  backend "s3" {
    bucket = "my-s3-backend-terraform-lab"
    key = "demo.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_user" "dev" {
    name = "user-01"
}

resource "aws_security_group" "prod" {
    name = "terraform-firewalls"
}