resource "aws_iam_role_policy" "api_invoke_policy" {
  name   = "APIInvokeStepFunction"
  role   = aws_iam_role.sign_up_state_machine.id
  policy = data.aws_iam_policy_document.step_function_integration.json
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${local.workshop_prefix}-api"
  protocol_type = "HTTP"
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

    resources = [aws_sfn_state_machine.user_sign_up.arn]
  }
}

resource "aws_iam_role" "api_gateway_step_function_integration" {
  name = "${local.workshop_prefix}-step-function-integration"

  assume_role_policy = data.aws_iam_policy_document.step_function_integration_assume.json
  inline_policy {
    name   = "InvokeStepFunction"
    policy = data.aws_iam_policy_document.step_function_integration.json
  }
}

resource "aws_apigatewayv2_integration" "step_function_integration" {
  api_id              = aws_apigatewayv2_api.this.id
  credentials_arn     = aws_iam_role.api_gateway_step_function_integration.arn
  integration_type    = "AWS_PROXY"
  integration_subtype = "StepFunctions-StartSyncExecution"
  request_parameters = {
    StateMachineArn = aws_sfn_state_machine.user_sign_up.arn
    Input           = "$request.body"
  }
}

resource "aws_apigatewayv2_route" "signup_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /signup"
  target    = "integrations/${aws_apigatewayv2_integration.step_function_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true


}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.this.api_endpoint
}