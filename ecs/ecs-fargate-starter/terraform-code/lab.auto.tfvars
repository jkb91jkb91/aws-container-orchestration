##############################################  SET YOUR OWN VALUES BELOW #########################################
###################################################################################################################
###################################################################################################################

# EXAMPLE region = "us-east-1"
region = "your value"

# EXAMPLE certificate_arn = "arn:aws:acm:us-east-1:311141565994:certificate/85a70a..................."
certificate_arn = "your value"

# EXAMPLE hosted_zone_name = "projectdevops.eu"
hosted_zone_name = "your value"

####################################################  ECS CLUSTER  ####################################################
# EXAMPLE cluster_name = "ecs-cluster"
cluster_name = "ecs-cluster"
# EXAMPLE log_group_name = "ecs-logs"
log_group_name = "ecs-logs"
# EXAMPLE logs_retention_in_days = 7
logs_retention_in_days = 7
###############################################  APPS LIST SERVICES+TASK ###############################################
apps = [
  {
    task_definition = {
      container = {
        name                 = "streamlit1" # USED ALSO AS PATH >>> DOMAIN/nginx >>> CONTAINER IMAGES HAS TO SET THAT TOO
        image_tag            = "jkb91/stramlitapp1:latest"
        container_port       = 8501
        healthcheck_path     = "http://localhost:8501/streamlit1" # REQUIRED HEALTH PATH
        stream_prefix        = "proxy"
        elb_healthcheck_path = "/streamlit1"
      }
      config = {
        family = "task-definition-app1"
        cpu    = "256"
        memory = "512"
      }
    }
    service_name  = "service-1"
    replica_count = 1
  }
  # TO ADD ANOTHER SERVICE JUST ADD SUCH BLOCK >>> CUSTOMIZE PARAMETERS, YOU CAN STILL USE jkb91/nginx_on_path_nginx_2:latest TO SEE HOW APP WORKS
  # ,
  # {
  #   task_definition = {
  #     container = {
  #       name                 = "streamlit2" # USED ALSO AS PATH >>> DOMAIN/nginx2 >>> CONTAINER IMAGES HAS TO SET THAT TOO
  #       image_tag            = "jkb91/stramlitapp2:latest"
  #       container_port       = 8501
  #       healthcheck_path     = "http://localhost:8501/streamlit2" # REQUIRED HEALTH PATH
  #       stream_prefix        = "proxy"
  #       elb_healthcheck_path = "/streamlit2"
  #     }
  #     config = {
  #       family = "task-definition-app2"
  #       cpu    = "256"
  #       memory = "512"
  #     }
  #   }
  #   service_name  = "service-2"
  #   replica_count = 1
  # }
]




