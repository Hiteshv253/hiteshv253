output "instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.instance_profile.name
}

output "role_name" {
  description = "The name of the IAM role created"
  value       = aws_iam_role.ec2_role.name
}
