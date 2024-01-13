resource "aws_sqs_queue" "lorem" {
  name = "MyHttpApiLorem"
  tags = local.tags

  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue_policy" "sqs_lorem" {
  queue_url = aws_sqs_queue.lorem.url
  policy    = data.aws_iam_policy_document.lorem.json
}

data "aws_iam_policy_document" "lorem" {
  statement {
    actions = [
      "sqs:SendMessage",
    ]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    resources = [
      aws_sqs_queue.lorem.arn,
    ]
  }
}