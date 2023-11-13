variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-west-2"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  type        = string
  default     = "nextjs-cluster"
}

variable "ecs_task_cpu" {
  description = "The number of CPU units to allocate for the ECS task."
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "The amount of memory (in MiB) to allocate for the ECS task."
  type        = string
  default     = "512"
}

variable "nextjs_image" {
  description = "The Docker image URL for the Next.js application."
  type        = string
  default     = "temporary/nextjs-image"  # Temporary default
}

variable "elb_name" {
  description = "The name of the Elastic Load Balancer."
  type        = string
  default     = "nextjs-elb"
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository for the Next.js app."
  type        = string
  default     = "nextjs-app"
}
