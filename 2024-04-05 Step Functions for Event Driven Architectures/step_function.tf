resource "aws_iam_role" "sign_up_state_machine" {
  name = "${local.workshop_prefix}-step-function-execution"

  assume_role_policy = data.aws_iam_policy_document.sign_up_state_machine_execution.json

  inline_policy {
    name = "sign-up-state-machine-policy"

    policy =  data.aws_iam_policy_document.sign_up_state_machine.json
  }
}

data "aws_iam_policy_document" "sign_up_state_machine" {
  statement {
    actions = ["dynamodb:PutItem"]

    resources = [aws_dynamodb_table.users.arn]
  }
}

data "aws_iam_policy_document" "sign_up_state_machine_execution" {
  statement {
    actions = ["sts:AssumeRole", ]

    principals {
      identifiers = ["states.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_sfn_state_machine" "user_sign_up" {
  name     = "${local.workshop_prefix}-user-sign-up"
  role_arn = aws_iam_role.sign_up_state_machine.arn

  type = "EXPRESS"

  definition = <<EOF
{
  "StartAt": "Store user in DynamoDB",
  "States": {
    "Store user in DynamoDB": {
      "Type": "Task",
      "Resource": "arn:aws:states:::dynamodb:putItem",
      "Parameters": {
        "TableName": "2024-04-05-workshop-users",
        "Item": {
          "Username": {
            "S.$": "$.username"
          }
        }
      },
      "Next": "HelloWorld"
    },
    "HelloWorld": {
      "Type": "Pass",
      "Result": "Hello World!",
      "End": true
    }
  }
}
EOF
}
