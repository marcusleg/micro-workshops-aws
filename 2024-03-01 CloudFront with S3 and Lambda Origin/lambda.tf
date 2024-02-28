locals {
  api_route_handler_function_name = "${local.workshop_prefix}-api-route-handler"
}

resource "aws_iam_role" "api_route_handler" {
  name = "${local.api_route_handler_function_name}_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_route_handler" {
  role       = aws_iam_role.api_route_handler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda/index.mjs"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "api_route_handler" {
  function_name = local.api_route_handler_function_name

  filename = data.archive_file.lambda.output_path
  handler = "index.handler"
  runtime = "nodejs20.x"
  role    = aws_iam_role.api_route_handler.arn
}

resource "aws_lambda_function_url" "api_route_handler" {
  function_name = aws_lambda_function.api_route_handler.function_name
  authorization_type = "NONE" # Use AWS_IAM for IAM-based authorization

  # Optional: Specify CORS settings if needed
  cors {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["POST", "GET"]
    allow_origins     = ["*"]
    max_age           = 3600
  }
}

output "lambda_function_url" {
  value = aws_lambda_function_url.api_route_handler.function_url
}
