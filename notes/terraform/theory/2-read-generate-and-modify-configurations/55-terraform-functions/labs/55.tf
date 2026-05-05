resource "aws_eip" "lb" {
    domain = "vpc"
}

output "demo" {
    value = var.app_port 
}