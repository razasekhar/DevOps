provider "aws" {
  region = "us-east-2"
}

# VPC and Subnet for ECS
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "ecs_subnet" {
  vpc_id     = aws_vpc.ecs_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.ecs_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "fargate-cluster"
}

# IAM Role for Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Definition for Fargate
resource "aws_ecs_task_definition" "node_app_task" {
  family                   = "node-app"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # Replace with the ECS task execution role ARN
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn # Replace with the ECS task role ARN

  container_definitions = jsonencode([{
    name      = "node-app-container"
    image     = "<image_url>"  # Replace with your Docker image URL
    essential = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "aws_cloudwatch_log_group.node_app_log_group.name"
        awslogs-region        = "us-east-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# ECS Service for Fargate
resource "aws_ecs_service" "ecs_service" {
  name            = "fargate-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.node_app_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.ecs_subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  desired_count = 1
}



resource "aws_iam_policy" "ecs_ecr_codepipeline_admin" {
  
  name        = "ECS-ECR-CodePipeline-Admin"
  description = "Admin access to ECS, ECR, and CodePipeline"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecs:*",
          "ecr:*",
          "codepipeline:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_codepipeline_admin_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_ecr_codepipeline_admin.arn
}


# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "node_app_log_group" {
  name = "/ecs/node-app"
}

# Create CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "node_app_log_stream" {
  name           = "app-logs"
  log_group_name = aws_cloudwatch_log_group.node_app_log_group.name
}

# Create ECS Task Definition (Sample)


# Create CloudWatch Alarm for High CPU Usage
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name                = "HighCPUUsage"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_actions             = [aws_sns_topic.ecs_alerts.arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name  # Replace with your ECS Cluster Name
    ServiceName = aws_ecs_service.ecs_service.name  # Replace with your ECS Service Name
  }
}

# Create SNS Topic for Notifications
resource "aws_sns_topic" "ecs_alerts" {
  name = "ecs-alerts"
}

# Subscribe to the SNS Topic
resource "aws_sns_topic_subscription" "ecs_alert_subscription" {
  topic_arn = aws_sns_topic.ecs_alerts.arn
  protocol  = "email"
  endpoint  = "rajashekhara.reddy@outlook.com"  # Replace with your email address
}


