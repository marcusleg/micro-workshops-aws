locals {
  function_name_content_moderator = "${local.workshop_prefix}-content-moderator"
  function_name_image_labeler     = "${local.workshop_prefix}-image-labeler"
}

// content moderator Lambda
resource "aws_iam_role" "content_moderator" {
  name = "${local.function_name_content_moderator}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name   = "content_moderator_lambda_policy"
    policy = data.aws_iam_policy_document.content_moderator_lambda_policy.json
  }
}

data "aws_iam_policy_document" "content_moderator_lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.profile_pictures.arn}/*"]
  }

  statement {
    actions = [
      "rekognition:DetectModerationLabels",
    ]

    resources = ["*"]

  }
}

resource "aws_iam_role_policy_attachment" "content_moderator" {
  role       = aws_iam_role.content_moderator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_content_moderator" {
  type        = "zip"
  source_file = "lambda-content-moderator/index.mjs"
  output_path = "lambda_function_payload_content_moderator.zip"
}

resource "aws_lambda_function" "content_moderator" {
  function_name = local.function_name_content_moderator

  filename         = data.archive_file.lambda_content_moderator.output_path
  source_code_hash = data.archive_file.lambda_content_moderator.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs20.x"
  role    = aws_iam_role.content_moderator.arn
}

resource "aws_lambda_permission" "content_moderator_allow_profile_pictures_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.content_moderator.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.profile_pictures.arn
}


// image labeler Lambda
resource "aws_iam_role" "image_labeler" {
  name = "${local.function_name_image_labeler}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name   = "image_labeler_lambda_policy"
    policy = data.aws_iam_policy_document.image_labeler_lambda_policy.json
  }
}

data "aws_iam_policy_document" "image_labeler_lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.profile_pictures.arn}/*"]
  }

  statement {
    actions = [
      "rekognition:DetectLabels",
    ]

    resources = ["*"]

  }
}

resource "aws_iam_role_policy_attachment" "image_labeler" {
  role       = aws_iam_role.image_labeler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_image_labeler" {
  type        = "zip"
  source_file = "lambda-image-labeler/index.mjs"
  output_path = "lambda_function_payload_image_labeler.zip"
}

resource "aws_lambda_function" "image_labeler" {
  function_name = local.function_name_image_labeler

  filename         = data.archive_file.lambda_image_labeler.output_path
  source_code_hash = data.archive_file.lambda_image_labeler.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs20.x"
  role    = aws_iam_role.image_labeler.arn
}

resource "aws_lambda_permission" "image_labeler_allow_profile_pictures_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_labeler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.profile_pictures.arn
}
