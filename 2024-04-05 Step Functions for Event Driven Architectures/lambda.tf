data "archive_file" "lambda_password_strength_validator" {
  type        = "zip"
  source_file = "lambda_password_strength_validator/validator.py"
  output_path = "lambda_password_strength_validator.zip"
}

resource "aws_iam_role" "password_strength_validator" {
  name = "${local.workshop_prefix}-password-strength-validator-execution-role"

  assume_role_policy = data.aws_iam_policy_document.password_strength_validator_execution_role.json
}

data "aws_iam_policy_document" "password_strength_validator_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "password_strength_validator" {
  role       = aws_iam_role.password_strength_validator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "password_strength_validator" {
  function_name = "${local.workshop_prefix}-password-strength-validator"

  filename = data.archive_file.lambda_password_strength_validator.output_path
  source_code_hash = data.archive_file.lambda_password_strength_validator.output_base64sha256

  handler = "validator.handler"
  runtime = "python3.12"
  role = aws_iam_role.password_strength_validator.arn
}