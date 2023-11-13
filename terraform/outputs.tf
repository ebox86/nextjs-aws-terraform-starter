output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.cluster.name
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.alb.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.nextjs_repository.repository_url
}
