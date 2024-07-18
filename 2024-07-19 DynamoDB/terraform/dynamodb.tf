resource "aws_dynamodb_table" "employee_skills" {
  name         = "${local.workshop_prefix}-employee-skills"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  global_secondary_index {
    name            = "SK-PK-index"
    hash_key        = "SK"
    range_key       = "PK"
    projection_type = "ALL"
  }
}

# Michael Jackson
resource "aws_dynamodb_table_item" "employee_michael_jackson" {
  table_name = aws_dynamodb_table.employee_skills.name
  hash_key   = aws_dynamodb_table.employee_skills.hash_key
  range_key  = aws_dynamodb_table.employee_skills.range_key

  item = <<ITEM
{
  "PK": {"S": "EMPLOYEE#01J33CZCCQGP9A1WDFTV0100ER"},
  "SK": {"S": "METADATA"},
  "Name": {"S": "Michael Jackson"},
  "Motto": {"S": "Hee Hee"}
}
ITEM
}

resource "aws_dynamodb_table_item" "employee_michael_jackson_skills" {
  for_each = toset(["Singing", "Dancing", "Moonwalking"])

  table_name = aws_dynamodb_table.employee_skills.name
  hash_key   = aws_dynamodb_table.employee_skills.hash_key
  range_key  = aws_dynamodb_table.employee_skills.range_key

  item = <<ITEM
{
  "PK": {"S": "EMPLOYEE#01J33CZCCQGP9A1WDFTV0100ER"},
  "SK": {"S": "SKILL#${upper(each.value)}"},
  "Skill": {"S": "${each.value}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "employee_michael_jackson_available_from" {
  table_name = aws_dynamodb_table.employee_skills.name
  hash_key   = aws_dynamodb_table.employee_skills.hash_key
  range_key  = aws_dynamodb_table.employee_skills.range_key

  item = <<ITEM
{
  "PK": {"S": "EMPLOYEE#01J33CZCCQGP9A1WDFTV0100ER"},
  "SK": {"S": "AVAILABLEFROM#2024-07-01"},
  "AvailableFrom": {"S": "2024-07-01"}
}
ITEM
}

# Alexi Laiho
resource "aws_dynamodb_table_item" "employee_alexi_laiho" {
  table_name = aws_dynamodb_table.employee_skills.name
  hash_key   = aws_dynamodb_table.employee_skills.hash_key
  range_key  = aws_dynamodb_table.employee_skills.range_key

  item = <<ITEM
{
  "PK": {"S": "EMPLOYEE#01J33RD5ZYMCZWSSQ0B76EGYGS"},
  "SK": {"S": "METADATA"},
  "Name": {"S": "Alexi Laiho"},
  "Motto": {"S": "I worship chaos"}
}
ITEM
}

resource "aws_dynamodb_table_item" "employee_alexi_laiho_skills" {
  for_each = toset(["Guitar", "Singing", "Composing"])

  table_name = aws_dynamodb_table.employee_skills.name
  hash_key   = aws_dynamodb_table.employee_skills.hash_key
  range_key  = aws_dynamodb_table.employee_skills.range_key

  item = <<ITEM
{
  "PK": {"S": "EMPLOYEE#01J33RD5ZYMCZWSSQ0B76EGYGS"},
  "SK": {"S": "SKILL#${upper(each.value)}"},
  "Skill": {"S": "${each.value}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "employee_alexi_laiho_available_from" {
  table_name = aws_dynamodb_table.employee_skills.name
  hash_key   = aws_dynamodb_table.employee_skills.hash_key
  range_key  = aws_dynamodb_table.employee_skills.range_key

  item = <<ITEM
{
  "PK": {"S": "EMPLOYEE#01J33RD5ZYMCZWSSQ0B76EGYGS"},
  "SK": {"S": "AVAILABLEFROM#2024-10-01"},
  "AvailableFrom": {"S": "2024-10-01"}
}
ITEM
}
