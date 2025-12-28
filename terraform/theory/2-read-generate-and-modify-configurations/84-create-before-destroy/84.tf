/*
The `create_before_destroy` meta-argument changes this behavior so that the new 
replacemnet object is created first, and the prior object is destroyed after the
replacement is created.
*/
provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "myec2" {
    ami = "ami-fe01jd1jwd1wdas"
    instance_type = "t2.micro"

    tags = {
        Name = "HelloEarth"
    }

    lifecycle {
        create_before_destroy = true
    }
}