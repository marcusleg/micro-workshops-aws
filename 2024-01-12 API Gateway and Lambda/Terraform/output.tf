output "api_gateway_url" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "queue_url" {
  value = aws_sqs_queue.lorem.id
}