output "app_subnets" {
  value = local.app_subnets_ids_sorted_by_az_name
}

output "dmz_subnets" {
  value = local.dmz_subnets_ids_sorted_by_az_name
}

output "web_subnets" {
  value = local.web_subnets_ids_sorted_by_az_name
}

output "vpc_id" {
  value = data.aws_vpc.vpc.id
}

output "app_subnet_ids" {
  value = data.aws_subnet_ids.app_subnet_ids.ids
}