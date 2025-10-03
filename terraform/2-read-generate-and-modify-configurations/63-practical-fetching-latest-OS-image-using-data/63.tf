provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "myami"  {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

output "print" {
    value = data.aws_ami.myami
}