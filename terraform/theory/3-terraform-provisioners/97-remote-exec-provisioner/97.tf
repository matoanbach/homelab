resource "aws_instance" "myec2" {
    ami = "ami-04oad12dfkj1f10e"
    instance_type = "t2.micro"
    key_name = "terraform-key"
    vpc_security_group_ids = ["sg-04n1ofd10d1dasf1"]

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("terraform-key.pem")
      host = self.public_ip
    }

    provisioner "remote-exec" {
        inline = [
            "yum -y install nginx",
            "systemctl start nginx",
        ]
    }
}