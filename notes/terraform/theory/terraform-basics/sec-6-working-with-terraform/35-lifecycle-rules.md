# Rules
## create_before_destroy
- main.tf
```tf
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    content = "We love pets!"
    file_permission = "0700"

    lifecycle {
        prevent_destroy = true
        # create_before_destroy = true
        # ignore_changes = true
    }
    lifecycle {
        ignore_changes = [
            tags
        ]
    }
}
```