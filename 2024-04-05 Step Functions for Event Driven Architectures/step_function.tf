resource "aws_iam_role" "sign_up_state_machine" {
  name = "${local.workshop_prefix}-step-function-execution"

  assume_role_policy = data.aws_iam_policy_document.sign_up_state_machine_execution.json
}

data "aws_iam_policy_document" "sign_up_state_machine_execution" {
  statement {
    actions = ["sts:AssumeRole",]

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
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Pass",
      "Result": "Hello World!",
      "End": true
    }
  }
}
EOF
}
