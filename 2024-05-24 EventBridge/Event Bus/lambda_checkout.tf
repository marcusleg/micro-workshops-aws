locals {
  api_route_handler_function_name = "${local.workshop_prefix}-checkout"
}

# Lambda role
resource "aws_iam_role" "checkout_lambda" {
  name = "${local.api_route_handler_function_name}_execution_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  inline_policy {
    name = "car_telemetry_ingest_lambda_policy"
    policy = data.aws_iam_policy_document.checkout_lambda_policy.json
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    sid = "AllowLambda"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "checkout_lambda_policy" {
  statement {
    actions = [
      "events:PutEvents",
    ]

    resources = [aws_cloudwatch_event_bus.web_shop.arn]
  }
}

resource "aws_iam_role_policy_attachment" "checkout_ingest_lambda" {
  role       = aws_iam_role.checkout_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_checkout" {
  type        = "zip"
  source_file = "lambda_checkout/index.mjs"
  output_path = "checkout_function_payload.zip"
}

resource "aws_lambda_function" "checkout" {
  function_name = local.api_route_handler_function_name

  filename         = data.archive_file.lambda_checkout.output_path
  source_code_hash = data.archive_file.lambda_checkout.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs20.x"
  role    = aws_iam_role.checkout_lambda.arn

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.web_shop.name
    }
  }
}

resource "aws_lambda_function_url" "checkout" {
  function_name      = aws_lambda_function.checkout.function_name
  authorization_type = "NONE"
}
