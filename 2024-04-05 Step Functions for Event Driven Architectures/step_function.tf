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

  statement {
    actions = ["sns:Publish",]

    resources = [aws_sns_topic.user_events.arn]
  }

  statement {
    actions = ["lambda:InvokeFunction"]

    resources = [aws_lambda_function.password_strength_validator.arn]
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
  "StartAt": "Verify password strength",
  "States": {
    "Verify password strength": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.password_strength_validator.arn}"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "ResultPath": "$.PasswordValidation",
      "Next": "If password is strong"
    },
    "If password is strong": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.PasswordValidation.Payload.passwordValid",
          "BooleanEquals": false,
          "Next": "Weak password"
        }
      ],
      "Default": "Query DynamoDB for username"
    },
    "Weak password": {
      "Type": "Fail",
      "Error": "WeakPasswordError",
      "Cause": "The password does not match out security requirements."
    },
    "Query DynamoDB for username": {
      "Type": "Task",
      "Resource": "arn:aws:states:::dynamodb:getItem",
      "Parameters": {
        "TableName": "2024-04-05-workshop-users",
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
      "Default": "Parallel"
    },
    "Parallel": {
      "Type": "Parallel",
      "Next": "Sign up complete",
      "Branches": [
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
                  },
                  "Password": {
                    "S.$": "$.password"
                  }
                }
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "Publish user signup event",
          "States": {
            "Publish user signup event": {
              "Type": "Task",
              "Resource": "arn:aws:states:::sns:publish",
              "Parameters": {
                "Message": {
                  "eventType": "signup",
                  "username.$": "$.username"
                },
                "TopicArn": "arn:aws:sns:eu-central-1:724792572405:2024-04-05-workshop-user-events"
              },
              "End": true
            }
          }
        }
      ]
    },
    "Username already exists": {
      "Type": "Fail",
      "Error": "UserExistsError",
      "Cause": "A user with the given username already exists."
    },
    "Sign up complete": {
      "Type": "Pass",
      "Result": "Sign up successful!",
      "Next": "Success"
    },
    "Success": {
      "Type": "Succeed"
    }
  }
}
EOF
}
