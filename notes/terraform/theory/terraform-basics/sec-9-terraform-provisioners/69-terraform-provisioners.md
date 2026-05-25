- main.tf
```terraform
resource "aws_instance" "webserver" {
    ami = "..."
    instance_type = "t2.micro"
    tags = {
        Name = "webserver"
        Description = "An Nginx WebServer on Ubuntu"
    }
    provisioner = [
        "sudo apt update",
        "sudo apt install nginx -y",
        "systemctl enable nginx",
        "systemctl start nginx"
    ]
    connect {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = file("/root/.ssh/web")
    }
    key_name = aws_key_pair.public_key
    vpc_security_group_ids = [ aws_security_group.ssh-access.id ]

}

resource "aws_security_group" "ssh-access" {

}

resource "aws_key_pair" "web" {

}