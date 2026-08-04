output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of Bastion host for administrative tunnels"
  value       = module.ec2.bastion_public_ip
}

output "app_private_ip" {
  description = "Private IP of Application server"
  value       = module.ec2.app_private_ip
}

output "db_endpoint" {
  description = "Endpoint address of RDS Database instance"
  value       = module.rds.db_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket created for assets storage"
  value       = module.s3.bucket_name
}
