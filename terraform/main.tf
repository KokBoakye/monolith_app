resource "aws_ecr_repository" "monolith_service" {
  name                 = "monolith-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true



}

resource "aws_ecs_cluster" "monolith" {
  name = "monolith-cluster"


}

resource "aws_vpc" "monolith" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

}

resource "aws_internet_gateway" "monolith_igw" {
  vpc_id = aws_vpc.monolith.id

}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.monolith.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.monolith_igw.id
  }
}

resource "aws_route_table_association" "public_assoc1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.monolith.id
  cidr_block              = "10.10.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1a"

}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.monolith.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1b"

}

resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_lb_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public1.id]

}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.monolith.id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.app_tg.arn
      }
    }
  }

}

resource "aws_ecs_task_definition" "monolith_task" {
  family                   = "monolith-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "monolith-app"
      image     = "${aws_ecr_repository.monolith_service.repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/monolith-service"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "monolith"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "monolith" {
  name              = "/ecs/monolith-service"
  retention_in_days = 7
}


resource "aws_ecs_service" "monolith_service" {
  name            = "monolith-service"
  cluster         = aws_ecs_cluster.monolith.id
  task_definition = aws_ecs_task_definition.monolith_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id, aws_subnet.public1.id]
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "monolith-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]

}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


