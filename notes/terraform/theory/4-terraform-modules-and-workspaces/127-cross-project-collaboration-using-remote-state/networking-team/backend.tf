terraform {
    backend "s3" {
        bucket = "some-bucket"
        key = "eip.tfstate"
        region = "us-east-1"
    }
}