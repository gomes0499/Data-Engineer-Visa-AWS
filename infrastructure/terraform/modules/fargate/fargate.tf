resource "aws_vpc" "airflow_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Airflow VPC"
  }
}

resource "aws_subnet" "airflow_subnet" {
  vpc_id     = aws_vpc.airflow_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Airflow Subnet"
  }
}

resource "aws_security_group" "airflow_sg" {
  name        = "Airflow Security Group"
  description = "Allow incoming traffic on specific ports for Airflow components"
  vpc_id      = aws_vpc.airflow_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "airflow_cluster" {
  name = "airflow"
}

resource "aws_ecs_task_definition" "airflow" {
  family                = "airflow"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = aws_iam_role.ecs_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "airflow-webserver"
      image     = "apache/airflow:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        {
          name  = "AIRFLOW__CORE__EXECUTOR"
          value = "CeleryExecutor"
        }
        # Additional environment variables as needed for your Airflow configuration
      ]
    }
    # Add container definitions for scheduler and worker
  ])
}



resource "aws_ecs_service" "airflow" {
  name            = "airflow"
  cluster         = aws_ecs_cluster.airflow_cluster.id
  task_definition = aws_ecs_task_definition.airflow.arn
  desired_count   = 1

  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.airflow_subnet.id]
    security_groups  = [aws_security_group.airflow_sg.id]
    assign_public_ip = true
  }
}


resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement : [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/your_required_policy"
  role       = aws_iam_role.ecs_task_role.name
}



