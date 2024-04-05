resource "aws_sns_topic" "user_events" {
  name = "${local.workshop_prefix}-user-events"
}

resource "aws_sns_topic_subscription" "user_events" {
  topic_arn = aws_sns_topic.user_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.user_events.arn

  raw_message_delivery = true
}

resource "aws_sqs_queue" "user_events" {
  name = "${local.workshop_prefix}-user-events"
}

resource "aws_sqs_queue_policy" "user_events" {
  queue_url = aws_sqs_queue.user_events.url
  policy    = data.aws_iam_policy_document.queue_policy_user_events.json
}

data "aws_iam_policy_document" "queue_policy_user_events" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.user_events.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sns_topic.user_events.arn
      ]
    }
  }
}