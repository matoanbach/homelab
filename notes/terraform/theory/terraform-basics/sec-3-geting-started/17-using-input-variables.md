- main.tf
```terraform
resource "local_file" "pet" {
    filename = var.filename
    content = var.content
}

resource "random_pet" "my_pet" {
    prefix = var.prefix
    sperator = var.seperator
    length = var.length
}
```
- variables.tf
```tf
variable "filename" {
    default = "/root/pets.txt"
}
variable "content" {
    default = "We love pets!"
}
variable "prefix" {
    default = "Mrs"
}
variable "seperator" {
    default = "."
}
variable "length" {
    default = "1"
}
```