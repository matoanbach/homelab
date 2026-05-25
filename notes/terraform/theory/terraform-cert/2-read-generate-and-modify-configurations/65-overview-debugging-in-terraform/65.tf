provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "myami" {
    owners = [ "amazon" ]
    most_recent = true
}

output "print" {
    value = data.aws_ami.myami
}

resource "local_file" "foo" {
    content = "foo!"
    filename = "${path.module}/foo.txt"
}