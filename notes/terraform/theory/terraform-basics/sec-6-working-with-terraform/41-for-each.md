# for each
```terraform
resource "local_file" "pet" {
    filename = each.value
    for_each = var.filename # toset(var.filename)
}

variable "filename" {
    type=set(string)
    default = [
        "file1",
        "file2",
        "file3"
    ]
}

outpet "pets" {
    value = local_file.pet
}
```