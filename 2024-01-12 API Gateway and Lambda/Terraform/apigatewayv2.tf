resource "aws_apigatewayv2_api" "this" {
  name          = "MyHttpApi"
  tags          = local.tags
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id = aws_apigatewayv2_api.this.id
  name   = "$default"
  tags   = local.tags

  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = "$context.extendedRequestId $context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api_gateway/${aws_apigatewayv2_api.this.name}"
  retention_in_days = 7
  tags              = local.tags
}

resource "aws_apigatewayv2_integration" "root_lambda" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  integration_uri        = aws_lambda_function.root_route.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.root_lambda.id}"
}

resource "aws_apigatewayv2_integration" "lorem_queue" {
  api_id              = aws_apigatewayv2_api.this.id
  credentials_arn     = aws_iam_role.integration_lorem_queue.arn
  integration_type    = "AWS_PROXY"
  integration_subtype = "SQS-SendMessage"

  request_parameters = {
    "QueueUrl"    = aws_sqs_queue.lorem.url
    "MessageBody" = "$request.body"
  }
}

resource "aws_apigatewayv2_route" "lorem" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /lorem"
  target    = "integrations/${aws_apigatewayv2_integration.lorem_queue.id}"
}

resource "aws_iam_role" "integration_lorem_queue" {
  name               = "MyHttpApiLoremQueue"
  assume_role_policy = data.aws_iam_policy_document.integration_lorem_queue_trust.json

  inline_policy {
    name   = "SqsSend"
    policy = data.aws_iam_policy_document.integration_lorem_queue_resource.json
  }
}

data "aws_iam_policy_document" "integration_lorem_queue_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "integration_lorem_queue_resource" {
  statement {
    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.lorem.arn,
    ]
  }
}