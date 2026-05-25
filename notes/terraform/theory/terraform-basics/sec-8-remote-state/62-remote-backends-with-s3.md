- main.tf
```terraform
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    content = "We love pets!"
}

terraform {
    backend "s3" {
        bucket = "kodekloud-terraform-state-bucket01"
        key = "finance/terraform.tfstate"
        region = "us-west-1"
        dynamodb_table = "state-locking"
    }
}
```