resource "aws_instance" "example" {
    ami = "ami-91d1dsf01kdf01e"
    instance_type = "t2.micro"
    depends_on = [aws_s3_bucket.example]
}

resource "aws_s3_bucket" "example" {
    bucket = "kplabs-demo-s3-007"
}