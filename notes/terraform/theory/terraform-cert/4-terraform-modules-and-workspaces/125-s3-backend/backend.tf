terraform {
  backend "s3" {
    bucket = "my-s3-backend-terraform-lab"
    key = "production.tfstate"
    region = "us-east-1"
    use_lockfile = "true"
  }
}