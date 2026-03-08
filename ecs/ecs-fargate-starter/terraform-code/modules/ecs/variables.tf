variable "execution_role_arn" {
  type        = string
  description = "execution_role_arn"
}

variable "task_role_arn" {
  type        = string
  description = "task_role_arn"
}

variable "subnet1_id" {
  type        = string
  description = "subnet1_id"
}

variable "subnet2_id" {
  type        = string
  description = "subnet2_id"
}

variable "sg1_id" {
  type        = string
  description = "sg1_id"
}

variable "log_group_name" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "logs_retention_in_days" {
  type = number
}

variable "apps" {
  type = list(object({
    task_definition = object({
      container = object({
        name             = string
        image_tag        = string
        container_port   = number
        healthcheck_path = string
        stream_prefix    = string
      })
      config = object({
        family = string
        cpu    = string
        memory = string
      })
    })
    service_name  = string
    replica_count = number
  }))
}

variable "target_group_arns" {
  type = map(string)
}