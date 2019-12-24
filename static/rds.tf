data "aws_vpc" "vpc" {
  filter {
    name = "tag:Environment"
    values = [
      var.environment
    ]
  }
}

variable "environment" {
  default = "dev"
}

data "aws_region" "current" {}

data "aws_subnet_ids" "data_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Class = "DATA"
  }
}

resource aws_db_subnet_group data_subnets {
  name       = "data_subnet"
  subnet_ids = data.aws_subnet_ids.data_subnets.ids
}

resource aws_rds_cluster "aurora" {
  cluster_identifier              = "rdscluster"
  engine                          = "aurora-mysql"
  database_name                   = "dev"
  master_username                 = "apmgateway"
  master_password                 = "apmgateway"
  skip_final_snapshot             = "true"
  db_subnet_group_name            = aws_db_subnet_group.data_subnets.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.data_parameters.name
}

resource aws_rds_cluster_parameter_group data_parameters {
  name   = "data-cluster-pg"
  family = "aurora-mysql5.7"
  //  parameter {
  //    name  = "binlog_format"
  //    value = "MIXED"
  //  }
  //  parameter {
  //    name  = "gtid_mode"
  //    value = "ON"
  //  }
}

resource aws_rds_cluster_instance data_instance {
  count                = 2
  identifier           = "datacluster-${count.index}"
  engine               = "aurora-mysql"
  cluster_identifier   = aws_rds_cluster.aurora.cluster_identifier
  instance_class       = "db.r5.xlarge"
  db_subnet_group_name = aws_db_subnet_group.data_subnets.name
}

locals {
  domain_name = "dev.endava-test-domain.be"
}

data "aws_route53_zone" "public_domain" {
  name         = "${local.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "public_record" {
  zone_id = data.aws_route53_zone.public_domain.zone_id
  name    = "rds.${data.aws_route53_zone.public_domain.name}"
  type    = "CNAME"
  ttl     = 300
  records = [
    #aws_rds_cluster_instance.data_instance[0].endpoint
    aws_rds_cluster.aurora.endpoint
  ]
}
