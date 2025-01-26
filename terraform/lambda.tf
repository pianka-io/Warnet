resource "aws_lambda_function" "orchestrator" {
  function_name = "orchestrator"
  filename      = "orchestrator.zip"
  source_code_hash = data.archive_file.python_lambda.output_base64sha256
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.13"
  handler       = "lambda_function.lambda_handler"
  timeout       = 10
}

data "archive_file" "python_lambda" {
  type = "zip"
  source_file = "../python/lambda_function.py"
  output_path = "orchestrator.zip"
}

resource "aws_cloudwatch_event_rule" "orchestrator_tick" {
  name                  = "orchestrator-tick"
  schedule_expression   = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "orchestrator_target" {
  target_id = "orchestrator-target"
  rule      = aws_cloudwatch_event_rule.orchestrator_tick.name
  arn       = aws_lambda_function.orchestrator.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orchestrator.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.orchestrator_tick.arn
}