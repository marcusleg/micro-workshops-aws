# resource "aws_api_gateway_rest_api" "this" {
#   name = "${local.workshop_prefix}-rest-api"
#
#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }
#
# resource "aws_api_gateway_integration" "signup_step_function_integration" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   resource_id = aws_api_gateway_resource.signup.id
#   http_method = aws_api_gateway_method.signup.http_method
#
#   integration_http_method = "POST"
#   type                    = "AWS"
#   uri                     = "arn:aws:apigateway:eu-central-1:states:action/StartExecution"
#   request_parameters = {
#     StateMachineArn = aws_sfn_state_machine.user_sign_up.arn
#   }
#
#   credentials = aws_iam_role.api_gateway_step_function_integration.arn
# }
#
# resource "aws_api_gateway_resource" "signup" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   parent_id   = aws_api_gateway_rest_api.this.root_resource_id
#   path_part   = "signup"
# }
#
# resource "aws_api_gateway_method" "signup" {
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   resource_id   = aws_api_gateway_resource.signup.id
#   http_method   = "POST"
#   authorization = "NONE"
# }
#
# output "aws_gateway_rest_api_url" {
#   value = aws_api_gateway_rest_api.this.endpoint_configuration
# }