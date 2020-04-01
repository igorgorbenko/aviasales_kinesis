output "arn" {
  description = "List of ARNs of instances"
  value       = aws_spot_instance_request.producer_instance.arn
}
