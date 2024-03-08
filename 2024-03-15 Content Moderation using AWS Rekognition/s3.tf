resource "random_string" "s3_bucket_profile_pictures_prefix" {
  length  = 12
  special = false
  upper   = false
}

resource "aws_s3_bucket" "profile_pictures" {
  bucket = "${local.workshop_prefix}-profile-pictures${random_string.s3_bucket_profile_pictures_prefix.result}"
}

resource "aws_s3_bucket_notification" "profile_pictures_content_moderation" {
  bucket = aws_s3_bucket.profile_pictures.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.content_moderator.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.content_moderator_allow_profile_pictures_bucket]
}

# S3 buckets can only have one notification configuration.
# Multiple Lambda functions in a notification configurations cannot share a common event type.
#resource "aws_s3_bucket_notification" "profile_pictures_image_labeler" {
#  bucket = aws_s3_bucket.profile_pictures.id
#
#  lambda_function {
#    lambda_function_arn = aws_lambda_function.image_labeler.arn
#    events              = ["s3:ObjectCreated:*"]
#  }
#
#  depends_on = [aws_lambda_permission.image_labeler_allow_profile_pictures_bucket]
#}