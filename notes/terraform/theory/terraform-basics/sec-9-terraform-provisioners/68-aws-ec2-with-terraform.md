- main.tf
```terraform
resource "aws_instance" "webserver" {
    ami = "..."
    instance_type = "t2.micro"
    tags = {
        Name = "webserver"
        Description = "An Nginx WebServer on Ubuntu"
    }
    user_data = <<EOF
    #! /bin/bash
        sudo apt update
        sudo apt install nginx -y
        systemctl enable nginx
        systemctl start nginx
    EOF

    key_name = aws_key_pair.public_key
    vpc_security_group_ids = [ aws_security_group.ssh-access.id ]
}

resource "aws_key_pair" "web" {
    public_key = file("/root/.ssh/web.pub)
}

resource "aws_security_group" "ssh-access" {
    name = "ssh-access"
    description = "AllowSSH access from the Internet"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```
- provider.tf
```terraform
provider "aws" {
    region = "us-west-1"
}
```