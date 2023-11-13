provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.101.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "MySubnet"
  }
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.102.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "MySubnet2"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}

# ECR Repository for Next.js App
resource "aws_ecr_repository" "nextjs_repository" {
  name = var.ecr_repository_name
  force_delete = true
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "nextjs"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name         = "nextjs",
      image        = "${aws_ecr_repository.nextjs_repository.repository_url}:latest",
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000,
        },
      ],
    },
  ])
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "nextjs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.my_subnet.id, aws_subnet.my_subnet_2.id]
    security_groups = [aws_security_group.sg.id]
  }

  desired_count = 1
}

# Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "nextjs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.my_subnet.id, aws_subnet.my_subnet_2.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "nextjs-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }
}

# Security Group for ALB and ECS
resource "aws_security_group" "sg" {
  name        = "nextjs-sg"
  description = "Allow traffic to ECS Fargate and ALB"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name   = "ecs_execution_policy"
  role   = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
