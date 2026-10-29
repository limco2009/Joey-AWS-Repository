# Expose our website and visualize it

output "static_website_endpoint" {
  # Below is the FQDN we can use to access our website, which is the S3 bucket website endpoint. This is the URL that we can use to access our static website hosted on S3.
  value       = aws_s3_bucket_website_configuration.codoMax_static_website.website_endpoint
  description = "The endpoint of the static website hosted on S3."

}
