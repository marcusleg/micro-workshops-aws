output "car_telemetry_ingest_api_endpoint" {
  value = "${aws_apigatewayv2_api.car_telemetry_ingest.api_endpoint}/ingest"
}