variable "environment" {
    default = "development"
}

resource "aws_instance" "myec2" {
    ami = "ami-052064a798f08f0d3"
    instance_type = var.environment == "development" ? "t2.micro" : "t2.medium" # conditionals in terraform
    count = 3
    tags = {
        Name = "payment-system-${count.index}"
    }
}

variable "dev_names" {
    type = list(string)
    default = ["alice", "bob", "johncorner"]
}

resource "aws_iam_user" "lb" {
    name = var.dev_names[count.index]
    count = length(var.dev_names)
}

