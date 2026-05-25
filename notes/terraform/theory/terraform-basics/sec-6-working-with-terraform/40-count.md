# count
```terraform
resource "local_file" "pet" {
    filename = var.filename[count.index]
    count = length(var.filename)
}

variable "filename" {
    default = [
        "file1",
        "file2",
        "file3"
    ]
}
```