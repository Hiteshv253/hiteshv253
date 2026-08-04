variable "aws_region" {
  description = "AWS Target Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment identifier (e.g. prod, staging)"
  type        = string
  default     = "prod"
}

variable "aws_account_id" {
  description = "AWS Account Identifier (12 digits)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public Subnets Cidr List"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private Subnets Cidr List"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Target Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "key_name" {
  description = "Name of SSH Key Pair in AWS Console"
  type        = string
}

variable "instance_type" {
  description = "App server instance type"
  type        = string
  default     = "t3.small"
}

variable "db_name" {
  description = "PostgreSQL DB schema name"
  type        = string
  default     = "laravel_prod"
}

variable "db_username" {
  description = "PostgreSQL root admin name"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "PostgreSQL root password"
  type        = string
  sensitive   = true
}

variable "allowed_admin_ips" {
  description = "Allowed IPs for Bastion SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
