variable "project" {
  type        = string
  description = "Logical project name used for tagging and resource names (e.g., lambda-image-resize)"
}

variable "source_bucket_arn" {
  type        = string
  description = "ARN of the uploads S3 bucket (without trailing /*)"
}

variable "dest_bucket_arn" {
  type        = string
  description = "ARN of the resized S3 bucket (without trailing /*)"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic for notifications"
}

