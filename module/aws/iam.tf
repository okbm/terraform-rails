resource "aws_iam_group" "rails-app" {
  name = "rails-app"
}

resource "aws_iam_group_policy" "rails-app-policy" {
  name        = "rails-app-policy"
  group       = "${aws_iam_group.rails-app.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "NotAction": [
        "iam:*",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "default" {
  name = "default"
  path = "/"
  force_destroy = true
}

resource "aws_iam_access_key" "default" {
  user = "${aws_iam_user.default.name}"
}

resource "aws_iam_group_membership" "default" {
  name = "rails-app-membership"
  users = [
      "default"
  ]
  group = "rails-app"
}
