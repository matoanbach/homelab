# data-source file
data "local_file" "foo" {
    filename = "${path.module}/demo.txt"
}

output "data" {
    value = data.local_file.foo.content
}

# data-source aws
provider "aws" {
  region = "us-east-1"
}

data "aws_instances" "example" {}