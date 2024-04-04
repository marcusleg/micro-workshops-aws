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
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]

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
  "StartAt": "Query DynamoDB for username",
  "States": {
      "Query DynamoDB for username": {
      "Type": "Task",
      "Resource": "arn:aws:states:::dynamodb:getItem",
      "Parameters": {
        "TableName": "${aws_dynamodb_table.users.name}",
        "Key": {
          "Username": {
            "S.$": "$.username"
          }
        }
      },
      "ResultPath": "$.DynamoDBResponse",
      "Next": "If username already exists"
    },
    "If username already exists": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.DynamoDBResponse.Item",
          "IsPresent": true,
          "Next": "Username already exists"
        }
      ],
      "Default": "Store user in DynamoDB"
    },
    "Username already exists": {
      "Type": "Fail",
      "Error": "UserExistsError",
      "Cause": "A user with the given username already exists."
    },
    "Store user in DynamoDB": {
      "Type": "Task",
      "Resource": "arn:aws:states:::dynamodb:putItem",
      "Parameters": {
        "TableName": "2024-04-05-workshop-users",
        "Item": {
          "Username": {
            "S.$": "$.username"
          },
          "Password": {
            "S.$": "$.password"
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
