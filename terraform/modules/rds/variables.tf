variable "vpc_id" {
  description = "VPC ID where DB security groups will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to attach the database subnet group to"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The security group ID of the app instance to allow connection"
  type        = string
}

variable "allocated_storage" {
  description = "Initial allocated DB storage size in GB"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "The database instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The database name"
  type        = string
}

variable "db_username" {
  description = "Database admin username"
  type        = string
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Deploy multi-AZ database instance"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}
