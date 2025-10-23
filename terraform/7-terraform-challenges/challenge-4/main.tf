variable input {}

provider aws {}

resource "aws_iam_user" "newuser" {
    name = "admin-user-${var.input}"
    lifecycle {
      prevent_destroy = true
    }
}

data "aws_iam_users" "users" {
}

output "users" {
    value = tolist(data.aws_iam_users.users.names)
    depends_on = [ aws_iam_user.newuser ]
}

output "users-length" {
    value = length(data.aws_iam_users.users.names)
}