resource "aws_iam_role" "ssm-maintenance-role" {
  name               = "${var.environment_prefix}-${var.product}-ssm-${var.service}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
  ]
}
EOF
}



resource "aws_iam_instance_profile" "ssm-maintenance-profile" {
  name = "${var.environment_prefix}-${var.product}-ssm-${var.service}-profile"
  role = aws_iam_role.ssm-maintenance-role.name
}

resource "aws_iam_role_policy_attachment" "ssm-attachment" {
  role       = aws_iam_role.ssm-maintenance-role.name
  policy_arn = aws_iam_policy.start-stop-policy.arn
}

resource "aws_iam_policy" "start-stop-policy" {
  name        = "${var.environment_prefix}-${var.product}-ssm-${var.service}-temp"
  description = "ssm-instance-start-stop"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}