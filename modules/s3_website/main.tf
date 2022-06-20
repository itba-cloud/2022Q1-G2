# ------------------------------------------------------------------------------
# Amazon S3 Main Website
# ------------------------------------------------------------------------------

# 1 - S3 bucket
resource "aws_s3_bucket" "main" {
  bucket              = var.bucket_name
  object_lock_enabled = false
}

resource "aws_s3_bucket_policy" "main" {
    bucket = aws_s3_bucket.main.id
    policy = data.aws_iam_policy_document.this.json
}

resource "aws_s3_bucket_acl" "main" {
    bucket = aws_s3_bucket.main.id
    acl    = "private"
}

resource "aws_s3_object" "main" {
    for_each =  fileset(var.export_path, "**")

    bucket        = aws_s3_bucket.main.id
    key           = each.value
    source        = format("%s/%s", var.export_path, each.value)
    content_type  = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
    storage_class = var.website_tier
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  index_document {
      suffix = "index.html"
    }

    error_document {
      key = "error.html"
    }
}

# ------------------------------------------------------------------------------
# Amazon S3 WWW Redirect
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.bucket_name}"
}

resource "aws_s3_bucket_acl" "www" {
    bucket = aws_s3_bucket.www.id
    acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.bucket

  redirect_all_requests_to {
      host_name = aws_s3_bucket.main.website_endpoint
    }

  depends_on = [aws_s3_bucket.main]
}

# ------------------------------------------------------------------------------
# Amazon S3 Logging
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "log" {
  bucket = "logs.${var.bucket_name}"
}

resource "aws_s3_bucket_acl" "log" {
  bucket = aws_s3_bucket.log.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "log" {
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.log.id
  target_prefix = "log/"
  depends_on = [aws_s3_bucket.main]
}
