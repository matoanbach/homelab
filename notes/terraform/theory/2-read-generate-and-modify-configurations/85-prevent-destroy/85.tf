/*
This meta-argument, when set to true, will cause Terraform to reject with an error any plan that 
would destroy the infrastructure object associated with the resource, as long as the argument
remains present in the configuration.
*/

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "myec2" {
    ami = "ami-0kfn1290fpsjf1"
    instance_type = "t2.micro"

    tags = {
        Name = "HelloEarth"
    }

    lifecycle {
      prevent_destroy = true
    }
}