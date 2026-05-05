provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "myec2" {
    ami = "ami-0fd3ac4abb734302a"
    instance_type = "t2.micro"
    tags = {
      "first-ec2": "will-never-let-you-down"
    }
}