# Multiple Providers
```terraform
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    content = "We love pets!"
}

resource "random_pet" "my_pet" {
    prefix = "Mrs"
    sperator = "."
    length = "1"
}
```