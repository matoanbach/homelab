# Resource Block

```hcl
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    content = "We love pets!"
}
```

## Example in AWS
```tf
resource "aws_instance" "webserver" {
    ami = "amd-aowu9ej1p0din1"
    instance_type = "t2.micro"
}
```

- Run the below
```bash
terraform init
terraform plan
terraform apply
terraform show
```