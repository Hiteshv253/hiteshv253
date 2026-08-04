output "app_public_ip" {
  description = "The public IP of the application server (if directly mapped, or use public DNS/LB)"
  value       = aws_instance.app.public_ip
}

output "app_private_ip" {
  description = "The private IP of the application server"
  value       = aws_instance.app.private_ip
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion host"
  value       = aws_instance.bastion.public_ip
}

output "app_security_group_id" {
  description = "Security group ID of the application server"
  value       = aws_security_group.app_sg.id
}
