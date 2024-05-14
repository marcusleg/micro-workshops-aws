resource "aws_schemas_registry" "web_shop" {
  name        = "${local.workshop_prefix}-web-shop"
}

resource "aws_schemas_schema" "checkout" {
  name          = "checkout"
  registry_name = aws_schemas_registry.web_shop.name
  type          = "OpenApi3"

  content = file("${path.module}/schemas/checkout.json")
}