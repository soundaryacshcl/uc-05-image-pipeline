resource "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
  tags   = { Project = var.project }
}

resource "aws_s3_bucket" "dest" {
  bucket = var.dest_bucket_name
  tags   = { Project = var.project }
}

