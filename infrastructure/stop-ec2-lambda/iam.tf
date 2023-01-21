resource "aws_iam_role" "lambda-infraestructure-role" {
  name               = "${var.environment_prefix}-${var.product}-${var.service}-role"
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
                "ecs:DiscoverPollEndpoint",
                "ecs:PutAccountSettingDefault",
                "ecs:CreateCluster",
                "autoscaling:*",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "ecs:DescribeTaskDefinition",
                "ecs:PutAccountSetting",
                "ecs:ListServices",
                "ecs:CreateCapacityProvider",
                "ecs:DeregisterTaskDefinition",
                "ecs:ListAccountSettings",
                "logs:CreateLogStream",
                "ecs:DeleteAccountSetting",
                "ecs:ListTaskDefinitionFamilies",
                "ecs:RegisterTaskDefinition",
                "ec2:*",
                "ecs:ListTaskDefinitions",
                "ecs:ListClusters",
                "ecs:CreateTaskSet"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ecs:*",
            "Resource": [
                "arn:aws:ecs:*:929226109038:cluster/*",
                "arn:aws:ecs:*:929226109038:service/*/*",
                "arn:aws:ecs:*:929226109038:capacity-provider/*",
                "arn:aws:ecs:*:929226109038:task-set/*/*/*",
                "arn:aws:ecs:*:929226109038:container-instance/*/*",
                "arn:aws:ecs:*:929226109038:task/*/*",
                "arn:aws:ecs:*:929226109038:task-definition/*:*"
            ]
        }
    ]
}
EOF
}