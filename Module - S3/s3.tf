resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "codoMax_static_website" {
  bucket = "codomax-terraform-s3-project-${random_id.bucket_suffix.hex}"
}

# This resource is to have the s3 bucket publicly accessible, 
# which is required for hosting a static website on S3.

resource "aws_s3_bucket_public_access_block" "codoMax_static_website" {
  bucket = aws_s3_bucket.codoMax_static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# This resource will only allow public read access to the objects in the bucket,
# but not to the bucket itself.

resource "aws_s3_bucket_policy" "codoMax_static_website_read" {
  bucket = aws_s3_bucket.codoMax_static_website.id

  # This line converts the policy from a Terraform map to a JSON string, 
  # which is required by the AWS S3 bucket policy.

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.codoMax_static_website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket.codoMax_static_website, aws_s3_bucket_public_access_block.codoMax_static_website]

}

# This resource enables static website hosting on the S3 bucket and specifies the index document.

resource "aws_s3_bucket_website_configuration" "codoMax_static_website" {
  bucket = aws_s3_bucket.codoMax_static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  # This resource depends on the bucket policy to ensure that the bucket is properly configured for public access before enabling website hosting.

  depends_on = [aws_s3_bucket_policy.codoMax_static_website_read]
}

# This resource is to upload 2 html files using terraform

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.codoMax_static_website.id
  key          = "index.html"
  source       = "${path.module}/build/index.html"
  etag         = filemd5("${path.module}/build/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.codoMax_static_website.id
  key          = "error.html"
  source       = "${path.module}/build/error.html"
  etag         = filemd5("${path.module}/build/error.html")
  content_type = "text/html"
}

