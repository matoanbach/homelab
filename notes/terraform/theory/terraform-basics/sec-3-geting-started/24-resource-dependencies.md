- main.tf
```tf
resource "local_file" "pet" {
    filename = var.filename
    content = "My favorite pet is Mr.Cat"
    depends_on = [
        random_pet.my_pet
    ]
}

resouce "random_pet" "my_pet" {
    prefix = var.prefix
    separator = var.separator
    length = var.length
}
```