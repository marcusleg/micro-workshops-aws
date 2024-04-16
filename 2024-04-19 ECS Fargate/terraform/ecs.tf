resource "aws_ecs_cluster" "fargate" {
  name = "${local.workshop_prefix}-fargate"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.fargate.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 50
    capacity_provider = "FARGATE"
  }
}

resource "aws_vpc" "fargate" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.fargate.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.fargate.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "subnet_3" {
  vpc_id     = aws_vpc.fargate.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-central-1c"
}

resource "aws_security_group" "fargate_sg" {
  name        = "fargate_sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.fargate.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" // 0.25 vCPU
  memory                   = "512" // 512MB

  container_definitions = jsonencode([
    {
      name      = "myapp"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "fargate_service" {
  name            = "my-fargate-service"
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
    security_groups = [aws_security_group.fargate_sg.id]
    assign_public_ip = true
  }

  desired_count = 1
}

