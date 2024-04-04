resource "aws_dynamodb_table" "users" {
  name = "${local.workshop_prefix}-users"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "Username"

  attribute {
    name = "Username"
    type = "S"
  }
}