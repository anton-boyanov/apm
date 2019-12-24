#----networking/main.tf

data "aws_availability_zones" "available" {}

#---VPC---

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Environment"
    values = [
      var.environment
    ]
  }
}
data "aws_region" "current" {
}
data "aws_subnet_ids" "app_subnet_ids" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Class = "APP"
  }
}
data "aws_subnet_ids" "dmz_subnet_ids" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Class = "DMZ"
  }
}
data "aws_subnet_ids" "web_subnet_ids" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Class = "WEB"
  }
}

data "aws_subnet" "app_subnets" {
  count = length(data.aws_subnet_ids.app_subnet_ids.ids)
  id = tolist(data.aws_subnet_ids.app_subnet_ids.ids)[count.index]
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Class = "APP"
  }
}
data "aws_subnet" "dmz_subnets" {
  count = length(data.aws_subnet_ids.dmz_subnet_ids.ids)
  id = tolist(data.aws_subnet_ids.dmz_subnet_ids.ids)[count.index]
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Class = "DMZ"
  }
}
data "aws_subnet" "web_subnets" {
  count = length(data.aws_subnet_ids.web_subnet_ids.ids)
  id = tolist(data.aws_subnet_ids.web_subnet_ids.ids)[count.index]
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Class = "WEB"
  }
}
locals {
  dmz_subnets_ids_sorted_by_az_name = values(zipmap(data.aws_subnet.dmz_subnets.*.availability_zone, data.aws_subnet.dmz_subnets.*.id))
  app_subnets_ids_sorted_by_az_name = values(zipmap(data.aws_subnet.app_subnets.*.availability_zone, data.aws_subnet.app_subnets.*.id))
  web_subnets_ids_sorted_by_az_name = values(zipmap(data.aws_subnet.web_subnets.*.availability_zone, data.aws_subnet.web_subnets.*.id))
}
