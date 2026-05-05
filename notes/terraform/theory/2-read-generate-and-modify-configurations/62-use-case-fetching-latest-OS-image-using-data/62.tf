provider "aws" {
    region = "us-east-1"
}

# # create 2 aws ec2 instances

variable "mode" {
    default = "development"
}

resource "aws_instance" "myec2" {
    ami = "ami-052064a798f08f0d3"
    instance_type = var.mode == "development" ? "t2.micro" : "t2.medium"
    tags = {
        Name = "instance-${count.index + 1}"
    }
    count = 2
}

output "print" {
    value = aws_instance.myec2
}

data "aws_ec2_instance_type_offerings" "example" {
    filter {
        name = "location"
        values = ["us-east-1"]
    }
}

output "print" {
    value = data.aws_ec2_instance_type_offerings.example.instance
}