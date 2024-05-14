resource "aws_cloudwatch_event_bus" "car_analytics" {
  name = "${local.workshop_prefix}-car-analytics"
}
