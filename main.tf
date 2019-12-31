provider "aws" {
  region = var.awsRegion
}
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  #required_version = "~>0.11.8"
}

# IAM
module "iam" {
  source      = "./iam"
  environment = var.environment
}

# Deploy networking resources
module "network" {
  source      = "./network"
  environment = var.environment
}

# Deploy security groups resources
module "security" {
  source           = "./security"
  application_name = var.application_name
  environment      = var.environment
}

module "create_cluster_logs" {
  source                        = "./logs_cluster"
  application_name              = var.application_name
  cloud_watch_retention_in_days = 1
  environment                   = var.environment
  merged_cluster_tags           = module.ecs.merged_cluster_tags
}

# Deploy compute resources

module "ecs" {
  source                       = "./ecs"
  enough_instances_per_cluster = var.enough_instances_per_cluster
  max_availability_zones       = var.max_availability_zones
  performance_level            = var.performance_level
  subnet_ids                   = module.network.app_subnet_ids
  subnets                      = module.network.app_subnets
  application_name             = var.application_name
  environment                  = var.environment
  key_name                     = var.key_name
  security_group               = module.security.instance_sg
  iam_instance_profile         = module.iam.ecs_instance_profile

  log_group_audit            = module.create_cluster_logs.audit
  log_group_cluster          = module.create_cluster_logs.cluster
  log_group_dmesg            = module.create_cluster_logs.dmesg
  log_group_docker           = module.create_cluster_logs.docker
  log_group_ecs_agent        = module.create_cluster_logs.ecs-agent
  log_group_ecs_init         = module.create_cluster_logs.ecs-init
  log_group_messages         = module.create_cluster_logs.messages
  log_group_ssm_agent        = module.create_cluster_logs.ssm-agent
  log_group_ssm_agent_errors = module.create_cluster_logs.ssm-agent-errors
}

module "nginx" {
  source = "./service_template"
  #--------------- ELB variables
  internal                      = false
  alb_port                      = 80
  alb_protocol                  = "HTTP"
  target_group_prefix           = "nginx"
  #--------------- ECS SERVICE variables
  service_name                  = "nginx"
  tasks_per_service             = 1
  container_port                = 80
  container_protocol            = "HTTP"
  environment_variables         = ""
  docker_tag                    = "latest"
  #--------------- Route53 variables
  domain                        = "endava-test-domain.be"
  #--------------- CloudWatch variables
  cloud_watch_retention_in_days = 1
  #--------------- autoscaling variables
  max_capacity = 4
  min_capacity = 1
  scale_down_adjustment = -1
  scale_down_cooldown = 300
  scale_up_adjustment = 1
  scale_up_cooldown = 60
  #--------------- GLOGAL variables
  application_name              = var.application_name
  environment                   = var.environment
  aws_region_name               = var.awsRegion
  apm_ecr_url                   = ""
  #--------------- IAM variables
  task_role_arn                 = module.iam.ecs_service_role
  ecs_service_role              = module.iam.ecs_service_role
  #--------------- NETWORK variables
  vpc_id                        = module.network.vpc_id
  subnets                       = module.network.app_subnets
  alb_security_group            = module.security.lb_sg
  #--------------- ECS variables
  ecs_cluster_id                = module.ecs.ecs_cluster_id
  tag_names                     = module.ecs.tag_names
  tags                          = module.ecs.tags
  merged_cluster_tags           = module.ecs.merged_cluster_tags
  }

module "httpd" {
  source = "./service_template"
  #--------------- ELB variables
  internal                      = false
  alb_port                      = 80
  alb_protocol                  = "HTTP"
  target_group_prefix           = "httpd"
  #--------------- ECS SERVICE variables
  service_name                  = "httpd"
  tasks_per_service             = 1
  container_port                = 80
  container_protocol            = "HTTP"
  environment_variables         = ""
  docker_tag                    = "latest"
  #--------------- Route53 variables
  domain                        = "endava-test-domain.be"
  #--------------- CloudWatch variables
  cloud_watch_retention_in_days = 1
  #--------------- autoscaling variables
  max_capacity = 4
  min_capacity = 1
  scale_down_adjustment = -1
  scale_down_cooldown = 300
  scale_up_adjustment = 1
  scale_up_cooldown = 60
  #--------------- GLOGAL variables
  application_name              = var.application_name
  environment                   = var.environment
  aws_region_name               = var.awsRegion
  apm_ecr_url                   = ""
  #--------------- IAM variables
  task_role_arn                 = module.iam.ecs_service_role
  ecs_service_role              = module.iam.ecs_service_role
  #--------------- NETWORK variables
  vpc_id                        = module.network.vpc_id
  subnets                       = module.network.app_subnets
  alb_security_group            = module.security.lb_sg
  #--------------- ECS variables
  ecs_cluster_id                = module.ecs.ecs_cluster_id
  tag_names                     = module.ecs.tag_names
  tags                          = module.ecs.tags
  merged_cluster_tags           = module.ecs.merged_cluster_tags
}
######################################################################################
//module "config" {
//  source       = "./service_template"
//  service_name = "configuration"
//  //  environment                       = var.environment
//  //  cluster_name                      = local.cluster_name
//  //  application_name                  = var.application_name
//  //  application_instance              = var.application_instance
//  //  log_group_name                    = aws_cloudwatch_log_group.configuration-service.name
//  //  docker_tag                        = var.environment
//  //  tasks_per_service                 = local.tasks_per_service
//  //  max_availability_zones            = var.max_availability_zones
//  //  apm_ecr_url                       = local.apm_ecr_url
//  //  environment_variables             = local.environment_variables
//  //  alb_security_group                = local.alb_security_group
//  //  tags                              = local.tags
//  //  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  //  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  //  merged_cluster_tags               = local.merged_cluster_tags
//  //  tag_names                         = local.tag_names
//  //  domain                            = data.aws_route53_zone.public_domain
//  //  certificate                       = data.aws_acm_certificate.public_ssl_cert
//
//  alb_port                          = ``
//  alb_protocol                      = ""
//  alb_security_group                = ""
//  apm_ecr_url                       = ""
//  app_subnets_ids_sorted_by_az_name = ""
//  application_instance              = ""
//  application_name                  = ""
//  aws_region_name                   = ""
//  certificate                       = ""
//  cluster_name                      = ""
//  container_port                    = ""
//  container_protocol                = ""
//  dmz_subnets_ids_sorted_by_az_name = ""
//  docker_tag                        = ""
//  domain                            = ""
//  ecs_cluster_id                    = ""
//  environment                       = ""
//  environment_variables             = ""
//  internal                          = ""
//  log_group_name                    = ""
//  max_availability_zones            = ""
//  merged_cluster_tags               = ""
//  subnets                           = ""
//  tag_names                         = ""
//  tags                              = ""
//  target_group_prefix               = ""
//  task_role_arn                     = ""
//  tasks_per_service                 = ""
//  vpc_id                            = ""
//}
//
//module "file-storage" {
//  source                            = "./control-svc-file-storage"
//  service_name                      = "file-storage"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.file-storage-service.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
//module "scheduler" {
//  source                            = "./control-svc-scheduler"
//  service_name                      = "scheduler"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.scheduler-service.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
//module "merchant-config" {
//  source                            = "./control-svc-merchant-config"
//  service_name                      = "merchant-config"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.merchant-config-service.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
//module "encryption" {
//  source                            = "./control-svc-encryption"
//  service_name                      = "encryption"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.encryption-service.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
//module "transaction" {
//  source                            = "./control-svc-transaction"
//  service_name                      = "transaction"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.transaction-service.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
//module "kafka" {
//  source                            = "./control-svc-kafka-zoo"
//  service_name                      = "kafka"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.kafka-zoo.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
//module "notification" {
//  source                            = "./control-svc-notification"
//  service_name                      = "notification"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.notification-service.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
////module "file-downloader" {
////  source                            = "./control-svc-file-downloader"
////  service_name                      = "file-downloader"
////  environment                       = var.environment
////  cluster_name                      = local.cluster_name
////  application_name                  = var.application_name
////  application_instance              = var.application_instance
////  log_group_name                    = aws_cloudwatch_log_group.file-downloader-service.name
////  docker_tag                        = var.environment
////  tasks_per_service                 = local.tasks_per_service
////  max_availability_zones            = var.max_availability_zones
////  apm_ecr_url                       = local.apm_ecr_url
////  environment_variables             = local.environment_variables
////  alb_security_group                = local.alb_security_group
////  tags                              = local.tags
////  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
////  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
////  merged_cluster_tags               = local.merged_cluster_tags
////  tag_names                         = local.tag_names
////  domain                            = data.aws_route53_zone.public_domain
////  certificate                       = data.aws_acm_certificate.public_ssl_cert
////  dependency                        = module.config.dependency
////}
//
//module "test-ppro" {
//  source                            = "./control-svc-test-ppro"
//  service_name                      = "test-ppro"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.test-ppro-simulator.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}
//
//module "merchant-boarding" {
//  source                            = "./control-svc-merchant-boarding"
//  service_name                      = "merchant-boarding"
//  environment                       = var.environment
//  cluster_name                      = local.cluster_name
//  application_name                  = var.application_name
//  application_instance              = var.application_instance
//  log_group_name                    = aws_cloudwatch_log_group.merchant-boarding-service.name
//  docker_tag                        = var.environment
//  tasks_per_service                 = local.tasks_per_service
//  max_availability_zones            = var.max_availability_zones
//  apm_ecr_url                       = local.apm_ecr_url
//  environment_variables             = local.environment_variables
//  alb_security_group                = local.alb_security_group
//  tags                              = local.tags
//  app_subnets_ids_sorted_by_az_name = local.app_subnets_ids_sorted_by_az_name
//  dmz_subnets_ids_sorted_by_az_name = local.dmz_subnets_ids_sorted_by_az_name
//  merged_cluster_tags               = local.merged_cluster_tags
//  tag_names                         = local.tag_names
//  domain                            = data.aws_route53_zone.public_domain
//  certificate                       = data.aws_acm_certificate.public_ssl_cert
//  dependency                        = module.config.dependency
//}



