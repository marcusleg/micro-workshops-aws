resource "aws_cloudwatch_event_bus" "web_shop" {
  name = "${local.workshop_prefix}-web-shop"
}
