- main.tf
```hcl
resource "aws_s3_bucket" "finance" {
    bucket = "finance-1231012"
    tags = {
        Description = "Finance and Payrole"
    }
}

resource "aws_s3_bucket_object" "finance-2023" {
    content = "/root/finance/finance-2020.doc"
    key = "finance-2020.doc"
    bucket = aws_s3_bucket.finance.id
}

data "aws_iam_group" "finance-data" {
    group_name = "finance-analysts"
}

resource "aws_s3_bucket_policy" "finance-policy" {
    bucket = aws_s3_bucket.finance.id
    policy = <<EOF
    {
        "Version": "2022-10-17",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${aws_s3_bcuket.finance.id}/",
        "Principal": {
            "AWS": [
                "${data.aws_iam_group.finance-data.arn}"
            ]
        }
    }
    EOF
}
```