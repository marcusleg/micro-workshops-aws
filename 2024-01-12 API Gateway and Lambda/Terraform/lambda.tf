data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = "AllowLambda"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "allow_logging" {
  statement {
    sid = "AllowLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_root_route" {
  name               = "ExecutionRoleMyHttpApiRootRouteLambda"
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "AllowCloudWatch"
    policy = data.aws_iam_policy_document.allow_logging.json
  }
}

resource "aws_lambda_function" "root_route" {
  function_name = "MyHttpApiRootRoute"
  tags          = local.tags
  handler       = "root.handler"
  runtime       = "nodejs20.x"

  role = aws_iam_role.lambda_root_route.arn

  filename = "lambda_root_route.zip"
  source_code_hash = data.archive_file.lambda_root_route.output_base64sha256
}

data "archive_file" "lambda_root_route" {
  type        = "zip"
  source_file = "lambda-function-code/root.mjs"
  output_path = "lambda_root_route.zip"
}

resource "aws_lambda_permission" "api_gateway" {
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.root_route.function_name

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*"
}