output "id" {
    description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com"
    value       = aws_s3_bucket.main.id
}

output "arn" {
    description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
    value       = aws_s3_bucket.main.arn
}

output "website_endpoint" {
    description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string"
    value       = aws_s3_bucket.main.website_endpoint
}

output "log_bucket_name" {
  value = aws_s3_bucket.log.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Bucket domain name for cloudfront"
  value = aws_s3_bucket.main.bucket_regional_domain_name
}
