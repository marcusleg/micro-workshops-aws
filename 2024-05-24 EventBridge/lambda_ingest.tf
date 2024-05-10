locals {
  api_route_handler_function_name = "${local.workshop_prefix}-car-telemetry-ingest"
}

# Lambda role
resource "aws_iam_role" "car_telemtry_ingest_lambda" {
  name = "${local.api_route_handler_function_name}_execution_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  inline_policy {
    name = "car_telemetry_ingest_lambda_policy"
    policy = data.aws_iam_policy_document.car_telemetry_ingest_lambda_policy.json
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

data "aws_iam_policy_document" "car_telemetry_ingest_lambda_policy" {
  statement {
    actions = [
      "events:PutEvents",
    ]

    resources = [aws_cloudwatch_event_bus.car_analytics.arn]
  }
}

resource "aws_iam_role_policy_attachment" "car_telemetry_ingest_lambda" {
  role       = aws_iam_role.car_telemtry_ingest_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
data "archive_file" "lambda_ingest" {
  type        = "zip"
  source_file = "lambda_ingest/index.mjs"
  output_path = "ingest_lambda_function_payload.zip"
}

resource "aws_lambda_function" "car_telemetry_ingest" {
  function_name = local.api_route_handler_function_name

  filename         = data.archive_file.lambda_ingest.output_path
  source_code_hash = data.archive_file.lambda_ingest.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs20.x"
  role    = aws_iam_role.car_telemtry_ingest_lambda.arn

  environment {
    variables = {
      CAR_ANALYTICS_EVENT_BUS_NAME = aws_cloudwatch_event_bus.car_analytics.name
    }
  }
}

# Function URL
resource "aws_lambda_function_url" "car_telemtry_ingest" {
  function_name      = aws_lambda_function.car_telemetry_ingest.function_name
  authorization_type = "NONE"
}
