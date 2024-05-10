terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }

  backend "s3" {
      bucket  = "backend-tfstate-gha"
      key     = "remote-state/terraform.tfstate"
      region  = "us-east-1"
  }
}


provider "aws" {
  region  = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_id
}

##### Creating a Random String #####
resource "random_string" "random" {
  length = 6
  special = false
  upper = false
} 

##### Creating an S3 Bucket #####
resource "aws_s3_bucket" "bucket" {
  bucket = "revbucket-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

##### will upload all the files present under HTML folder to the S3 bucket #####
resource "aws_s3_object" "upload_object" {
  for_each      = fileset("public/", "*")
  bucket        = aws_s3_bucket.bucket.id
  key           = each.value
  source        = "public/${each.value}"
  etag          = filemd5("public/${each.value}")
  content_type  = "text/html"
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}