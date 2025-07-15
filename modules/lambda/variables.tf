variable "project" { type = string }
variable "role_arn" { type = string }
variable "source_bucket_id" { type = string }
variable "dest_bucket_name" { type = string }
variable "sns_topic_arn" { type = string }

variable "layer_s3_bucket" { type = string }
variable "layer_s3_key" { type = string }

variable "lambda_s3_bucket" { type = string }
variable "lambda_s3_key" { type = string }

variable "memory_size" {
  description = "Lambda memory (MB)"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Lambda timeout (seconds)"
  type        = number
  default     = 30
}
variable "source_bucket_arn" {
  description = "Full ARN of the source S3 bucket (for Lambda invoke permission)"
  type        = string
}
