resource "aws_iam_user" "lb" {
    name = "provisioner-user"

    provisioner "local-exec" {
      command = "This is creation time provisioner"
    }

    provisioner "local-exec" {
      command = "echo This is detroy time provisioner"
      when = destroy
    }
}