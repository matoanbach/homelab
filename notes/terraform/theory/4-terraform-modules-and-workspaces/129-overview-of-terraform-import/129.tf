provider "aws" {
    region = "us-east-1"
}

import {
    to = aws_security_group.mysq
    id = "sg-0854c969a0d41a2b6"
}