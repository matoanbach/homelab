resource "aws_security_group" "allow_tls" {
    name = "allow_tls"
}

data "terraform_remote_state" "eip" {
    backend = "s3"
    config = {
        bucket = "some-bucket"
        key = "eip.tfstate"
        region = "us-east-1"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
    security_group_id = aws_security_group.allow_tls.id
    cidr_ipv4 = "${data.terraform_remote_state.eip.outputs.eip_addr}" 
    from_port = 443
    ip_protocol = "tcp"
    to_port = 443
}