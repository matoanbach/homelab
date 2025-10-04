resource "aws_instance" "myec2" {
    ami = "ami-d0d1ndsadf01we"
    instance_type = "t2.micro"

    provisioner "local-exec" {
      command = "echo ${self.private_ip} >> server_ip.txt"
    }
}