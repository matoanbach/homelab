variable "sq_ports" {
    type = list(number)
    description = "list of ingress ports"
    default = [8200, 8201, 8300, 9200, 9500]
}

resource "aws_security_group" "dynamicsq" {
    name = "dynamic-sg"
    description = "Ingress for Vault"

    dynamic "ingress" {
        for_each = var.sq_ports
        content {
          from_port = ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
    }
}