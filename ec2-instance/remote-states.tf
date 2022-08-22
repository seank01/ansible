locals {
  remote_states = {
    "network" = data.terraform_remote_state.this["network"].outputs
  }
  vpc           = local.remote_states["network"].vpc
  subnet_groups = local.remote_states["network"].subnet_groups
}

data "terraform_remote_state" "this" {
  for_each = local.config.remote_states

  backend = "remote"

  config = {
    organization = each.value.organization
    workspaces = {
      name = each.value.workspace
    }
  }
}

/* #기존 수정전
data "terraform_remote_state" "this" {
  for_each = local.config.remote_states

  backend = "remote"

  config = {
    organization = each.value.organization
    workspaces = {
      name = each.value.workspace
    }
  }
} */


/* data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "${path.module}/../network/terraform.tfstate"
  }
}

locals {
  vpc_name      = data.terraform_remote_state.network.outputs.vpc_name
  subnet_groups = data.terraform_remote_state.network.outputs.subnet_groups
} */

/* ###################################################
# VPC
###################################################

module "vpc" {
  source  = "tedilabs/network/aws//modules/vpc"
  version = "0.24.0"

  name                  = local.config.vpc.name
  cidr_block            = local.config.vpc.cidr

  internet_gateway_enabled = true

  dns_hostnames_enabled = true
  dns_support_enabled   = true

  tags = local.common_tags
} */

###################################################
# Subnet Groups
###################################################

/* module "subnet_group" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  for_each = local.config.subnet_groups

  name                    = "${module.vpc.name}-${each.key}"
  vpc_id                  = module.vpc.id
  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)

  subnets = {
    for idx, subnet in try(each.value.subnets, []) :
    "${module.vpc.name}-${each.key}-${format("%03d", idx + 1)}/${regex("az[0-9]", subnet.az_id)}" => {
      cidr_block           = subnet.cidr
      availability_zone_id = subnet.az_id
    }
  }

  tags = local.common_tags
} */