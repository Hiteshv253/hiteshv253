variable "aws_account_id" {
  description = "AWS Account ID used to create a unique bucket name"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}
