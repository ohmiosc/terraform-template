resource "aws_lambda_function" "stop_lambda_function" {
  function_name    = "${var.environment_prefix}-${var.product}-${var.service}-function"
  filename         = "nametest.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda-infraestructure-role.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  timeout          = 10
}
resource "aws_cloudwatch_event_rule" "event-lambda" {
  name        = "${var.environment_prefix}-${var.product}-${var.service}-event"
  description = "Schedule lambda function"
  #schedule_expression   = "rate(60 minutes)"
  schedule_expression = "cron(15 00 * * ? *)"
}
resource "aws_cloudwatch_event_target" "lambda-function-target" {
  target_id = "lambda-function-target"
  rule      = aws_cloudwatch_event_rule.event-lambda.name
  arn       = aws_lambda_function.stop_lambda_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.stop_lambda_function.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.event-lambda.arn
}