resource "aws_iam_role" "lambda-infraestructure-role" {
  name               = "${var.environment_prefix}-${var.product}-stop-${var.service}-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}



resource "aws_iam_instance_profile" "lambda-infraestructure-profile" {
  name = "${var.environment_prefix}-${var.product}-stop-${var.service}-profile"
  role = aws_iam_role.lambda-infraestructure-role.name
}

resource "aws_iam_role_policy_attachment" "lambda-attachment" {
  role       = aws_iam_role.lambda-infraestructure-role.name
  policy_arn = aws_iam_policy.start-stop-policy.arn
}

resource "aws_iam_policy" "start-stop-policy" {
  name        = "${var.environment_prefix}-${var.product}-stop-${var.service}-temp"
  description = "lambda-instance-start-stop"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "ec2:*",
                "autoscaling:*",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}