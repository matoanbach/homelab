variable "sensitive_content" {
    sensitive = true
    default = "supersecret"
}

resource "local_file" "foo" {
    content = var.sensitive_content
    filename = "password.txt"
}

output "content" {
    value = local_file.foo.content
    sensitive = "true"
}