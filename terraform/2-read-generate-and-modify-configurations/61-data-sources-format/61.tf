provider "aws" {
    region = "us-east-1"
}

# create 2 aws ec2 instances

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

data "aws_instance" "foo" {
    # instance_id = "i-0eb0484a6f0ee98f9"
    filter {
        name = "tag:Name"
        values = ["instance-1"]
    }
}

output "foo_data" {
    value = data.aws_instance.foo
}