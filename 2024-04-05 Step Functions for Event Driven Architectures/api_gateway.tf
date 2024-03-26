# IAM Role for the Step Function
resource "aws_iam_role" "step_function_role" {
  name = "${local.workshop_prefix}-stepFunctionExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
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

# IAM Policy to allow Step Function to be called by API Gateway
resource "aws_iam_role_policy" "api_invoke_policy" {
  name   = "APIInvokeStepFunction"
  role   = aws_iam_role.step_function_role.id
  policy = data.aws_iam_policy_document.api_invoke_policy_doc.json
}

data "aws_iam_policy_document" "api_invoke_policy_doc" {
  statement {
    actions   = ["states:StartExecution"]
    resources = ["*"] # Specify your Step Function ARN for better security

    effect = "Allow"
  }
}

# Step Function State Machine
resource "aws_sfn_state_machine" "sample_state_machine" {
  name     = "${local.workshop_prefix}-SampleStateMachine"
  role_arn = aws_iam_role.step_function_role.arn

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

# API Gateway v2
resource "aws_apigatewayv2_api" "example_api" {
  name          = "${local.workshop_prefix}-exampleAPI"
  protocol_type = "HTTP"
  description   = "Example API for Step Function integration"
}

# Integration between API Gateway and Step Function
resource "aws_apigatewayv2_integration" "step_function_integration" {
  api_id           = aws_apigatewayv2_api.example_api.id
  credentials_arn  = aws_iam_role.step_function_role.arn
  integration_type = "AWS_PROXY"
  integration_subtype = "StepFunctions-StartSyncExecution"
  request_parameters = {
    StateMachineArn = aws_sfn_state_machine.sample_state_machine.arn
  }
}

# Default route for the API Gateway
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.example_api.id
  route_key = "POST /execute"
  target    = "integrations/${aws_apigatewayv2_integration.step_function_integration.id}"
}

# Deploy the API
resource "aws_apigatewayv2_stage" "example_stage" {
  api_id      = aws_apigatewayv2_api.example_api.id
  name        = "exampleStage"
  auto_deploy = true
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.example_api.api_endpoint
}