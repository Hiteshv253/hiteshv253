variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets IDs for Bastion host"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnets IDs for App hosts"
  type        = list(string)
}

variable "allowed_admin_ips" {
  description = "IP addresses allowed to SSH to the Bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for app server"
  type        = string
  default     = "t3.small"
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for the app server"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}
