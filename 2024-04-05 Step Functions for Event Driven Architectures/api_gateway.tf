# IAM Role for the Step Function
resource "aws_iam_role" "step_function_role" {
  name = "${local.workshop_prefix}-stepFunctionExecutionRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "api_invoke_policy" {
  name   = "APIInvokeStepFunction"
  role   = aws_iam_role.step_function_role.id
  policy = data.aws_iam_policy_document.step_function_integration.json
}

data "aws_iam_policy_document" "api_invoke_policy_doc" {
  statement {
    actions = ["states:StartExecution", "states:StartSyncExecution"]
    resources = ["*"] # Specify Step Function ARN for better security

    effect = "Allow"
  }
}

resource "aws_sfn_state_machine" "sample_state_machine" {
  name     = "${local.workshop_prefix}-SampleStateMachine"
  role_arn = aws_iam_role.step_function_role.arn

  type = "EXPRESS"

  definition = <<EOF
{
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Pass",
      "Result": "Hello World!",
      "End": true
    }
  }
}
EOF
}

resource "aws_apigatewayv2_api" "example_api" {
  name          = "${local.workshop_prefix}-exampleAPI"
  protocol_type = "HTTP"
  description   = "Example API for Step Function integration"
}

data "aws_iam_policy_document" "step_function_integration_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "step_function_integration" {
  statement {
    actions = ["states:StartExecution", "states:StartSyncExecution"]

    resources = [aws_sfn_state_machine.sample_state_machine.arn]
  }
}

resource "aws_iam_role" "step_function_integration" {
  name = "${local.workshop_prefix}-stepFunctionIntegrationRole"

  assume_role_policy = data.aws_iam_policy_document.step_function_integration_assume.json
  inline_policy {
    name   = "InvokeStepFunction"
    policy = data.aws_iam_policy_document.step_function_integration.json
  }
}

resource "aws_apigatewayv2_integration" "step_function_integration" {
  api_id              = aws_apigatewayv2_api.example_api.id
  credentials_arn     = aws_iam_role.step_function_integration.arn
  integration_type    = "AWS_PROXY"
  integration_subtype = "StepFunctions-StartSyncExecution"
  request_parameters = {
    StateMachineArn = aws_sfn_state_machine.sample_state_machine.arn
  }
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.example_api.id
  route_key = "POST /execute"
  target    = "integrations/${aws_apigatewayv2_integration.step_function_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.example_api.id
  name        = "$default"
  auto_deploy = true


}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.example_api.api_endpoint
}