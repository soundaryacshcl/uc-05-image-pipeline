output "source_bucket_id" {
  value = aws_s3_bucket.source.id
}

output "source_bucket_name" {
  value = aws_s3_bucket.source.bucket
}

output "dest_bucket_name" {
  value = aws_s3_bucket.dest.bucket
}

output "source_bucket_arn" {
  value = aws_s3_bucket.source.arn
}