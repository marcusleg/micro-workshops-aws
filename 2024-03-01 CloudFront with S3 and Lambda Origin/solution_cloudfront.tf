locals {
  origin_id_s3_static_web_assets = "S3Origin"
  origin_id_lambda_handler = "LambdaOrigin"
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = local.workshop_prefix

  default_root_object = "index.html"
  http_version        = "http2and3" # http1.1 is supported by default

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  origin {
    origin_id                = local.origin_id_s3_static_web_assets
    domain_name              = aws_s3_bucket.static_website_assets.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.static_web_assets.id
  }

    origin {
      origin_id   = local.origin_id_lambda_handler
      domain_name = regex("//(.+)/", aws_lambda_function_url.api_route_handler.function_url).0

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

    compress = true

    target_origin_id = local.origin_id_s3_static_web_assets

    viewer_protocol_policy = "redirect-to-https"
  }

    ordered_cache_behavior {
      path_pattern    = "/api/*"
      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer.id
      response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

      compress = true

      target_origin_id = local.origin_id_lambda_handler

      viewer_protocol_policy = "redirect-to-https"
    }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "aws_cloudfront_origin_access_control" "static_web_assets" {
  name        = "${local.workshop_prefix}-static-web-assets"
  description = "Signs S3 GetObject requests by CloudFront distribution"

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  # Find the list of managed policies provided by AWS here:
  # https://us-east-1.console.aws.amazon.com/cloudfront/v3/home?region=us-east-1#/policies/cache
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  # Find the list of managed policies provided by AWS here:
  # https://us-east-1.console.aws.amazon.com/cloudfront/v3/home?region=us-east-1#/policies/cache
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewerExceptHostHeader"
}

data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.this.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}