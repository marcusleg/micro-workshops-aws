resource "random_string" "s3_bucket_static_website_assets_prefix" {
  length  = 12
  special = false
  upper   = false
}

resource "aws_s3_bucket" "static_website_assets" {
  bucket = "${local.workshop_prefix}-static-website-assets-${random_string.s3_bucket_static_website_assets_prefix.result}"

  force_destroy = true # not recommended for production use
}

resource "aws_s3_bucket_website_configuration" "static_website_assets" {
  bucket = aws_s3_bucket.static_website_assets.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "static_website_assets" {
  bucket = aws_s3_bucket.static_website_assets.id
  key    = "/index.html"

  source       = "static-website-assets/index.html"
  content_type = "text/html; charset=utf-8"

  force_destroy = true
}