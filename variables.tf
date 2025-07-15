variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "project" {
  description = "Project prefix for resource names"
  type        = string
}

variable "source_bucket_name" {
  type = string
}

variable "dest_bucket_name" {
  type = string
}

variable "subscription_email" {
  type = string
}
