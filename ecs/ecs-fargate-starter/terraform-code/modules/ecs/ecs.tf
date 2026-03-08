resource "aws_ecs_cluster" "fargate_cluster" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = var.log_group_name
  retention_in_days = var.logs_retention_in_days

  tags = {
    Name = var.log_group_name
  }
}

resource "aws_cloudwatch_log_group" "apps" {
  for_each          = local.apps_by_name
  name              = "/ecs/${each.key}"
  retention_in_days = var.logs_retention_in_days
}

locals {
  apps_by_name = {
    for app in var.apps : app.task_definition.container.name => {
      container_definition = {
        name      = app.task_definition.container.name
        image     = app.task_definition.container.image_tag
        essential = true
        portMappings = [
          {
            containerPort = app.task_definition.container.container_port
            protocol      = "tcp"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-create-group  = "true"
            awslogs-group         = "/ecs/${app.task_definition.container.name}"
            awslogs-region        = var.region
            awslogs-stream-prefix = app.task_definition.container.stream_prefix
          }
        }
        healthCheck = {
          command     = ["CMD-SHELL", "curl -f ${app.task_definition.container.healthcheck_path} || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 10
        }
      }
      task_config      = app.task_definition.config
      service_name     = app.service_name
      replica_count    = app.replica_count
      target_group_arn = var.target_group_arns[app.task_definition.container.name]
    }
  }
}

#-------------------------APPS TASK+SERVICE------------------------------------
resource "aws_ecs_task_definition" "app" {
  for_each                 = local.apps_by_name
  family                   = each.value.task_config.family
  cpu                      = each.value.task_config.cpu
  memory                   = each.value.task_config.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = jsonencode([each.value.container_definition])
}

resource "aws_ecs_service" "app" {
  enable_execute_command = true
  force_new_deployment   = true
  for_each               = local.apps_by_name
  name                   = each.value.service_name
  cluster                = var.cluster_name
  task_definition        = aws_ecs_task_definition.app[each.key].arn
  desired_count          = each.value.replica_count
  launch_type            = "FARGATE"

  load_balancer {
    target_group_arn = each.value.target_group_arn
    container_name   = each.key
    container_port   = each.value.container_definition.portMappings[0].containerPort
  }

  network_configuration {
    subnets          = [var.subnet1_id, var.subnet2_id]
    security_groups  = [var.sg1_id]
    assign_public_ip = false
  }
  depends_on = [aws_ecs_task_definition.app]
}

