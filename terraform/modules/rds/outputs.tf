output "db_endpoint" {
  description = "The database endpoint to connect to"
  value       = aws_db_instance.postgres.endpoint
}

output "db_address" {
  description = "The IP address or domain host of the database"
  value       = aws_db_instance.postgres.address
}
