provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "myec2" {
    ami = "ami-08982f1c5bf93d976"
    instance_type = "t2.micro"
    tags = {
        Name = "my-first-ec2"
    }
}