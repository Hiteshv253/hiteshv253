variable "bucket_arn" {
  description = "The ARN of the S3 bucket to allow access to"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}
