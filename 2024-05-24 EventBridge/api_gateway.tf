resource "aws_apigatewayv2_api" "car_telemetry_ingest" {
  name          = "${local.workshop_prefix}-car-telemetry-ingest"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "car_telemetry_ingest_api_gateway_logs" {
  name              = "/aws/apigateway/${local.workshop_prefix}-car-telemetry-ingest"
  retention_in_days = 7
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.car_telemetry_ingest.id
  name        = "default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.car_telemetry_ingest_api_gateway_logs.arn
    format          = jsonencode({
      requestId      = "$context.requestId",
      ip             = "$context.identity.sourceIp",
      requestTime    = "$context.requestTime",
      httpMethod     = "$context.httpMethod",
      resourcePath   = "$context.resourcePath",
      status         = "$context.status",
      protocol       = "$context.protocol",
      responseLength = "$context.responseLength"
    })
  }
}

resource "aws_apigatewayv2_integration" "eventbridge_integration" {
  api_id              = aws_apigatewayv2_api.car_telemetry_ingest.id
  integration_type    = "AWS_PROXY"
  integration_subtype = "EventBridge-PutEvents"

  request_parameters = {
    "Detail"       = "$request.body"
    "DetailType"   = aws_schemas_schema.car_telemetry.name
    "EventBusName" = aws_cloudwatch_event_bus.car_analytics.name
    "Source"       = "com.example.telemetry"
  }

  credentials_arn        = aws_iam_role.apigateway_integration_role.arn
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "ingest_route" {
  api_id    = aws_apigatewayv2_api.car_telemetry_ingest.id
  route_key = "POST /ingest"
  target    = "integrations/${aws_apigatewayv2_integration.eventbridge_integration.id}"
}

resource "aws_iam_role" "apigateway_integration_role" {
  name = "apigateway-eventbridge-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "apigateway_eventbridge_policy" {
  role = aws_iam_role.apigateway_integration_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = "events:PutEvents",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}