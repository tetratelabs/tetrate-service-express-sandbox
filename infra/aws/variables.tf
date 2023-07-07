variable "name_prefix" {
  type    = string
  description = "name prefix"
}

variable "cluster_id" {
  type    = string
  default = null
}

variable "cluster_name" {
  type    = string
  default = null
}

variable "region" {
}

variable "k8s_version" {
  default = "1.23"
}

variable "cidr" {
  type    = string
  description = "cidr"
  default     = "172.20.0.0/16"
}

variable "jumpbox_username" {
  default = "tetrate-admin"
}

variable "output_path" {
  default = "../../outputs"
}

variable "tetrate" {
  type    = map
  default = {}
}

locals {
  tetrate_defaults = {
    fqdn                 = "demo"
    version              = "demo"
    image_sync_username  = "demo"
    image_sync_apikey    = "demo"
    password             = "Tetrate123"
    tags                 = {
      tetrate_owner      = "demo"
      tetrate_team       = "demo"
      tetrate_purpose    = "demo"
      tetrate_lifespan   = "demo"
      tetrate_customer   = "demo"
    }
  }
  tetrate = merge(local.tetrate_defaults, var.tetrate)
}

locals {
  default_tags = {
       "tetrate:owner"    = coalesce(local.tetrate.tags.tetrate_owner, replace(local.tetrate.image_sync_username, "/\\W+/", "-"))
       "tetrate:team"     = local.tetrate.tags.tetrate_team
       "tetrate:purpose"  = local.tetrate.tags.tetrate_purpose
       "tetrate:lifespan" = local.tetrate.tags.tetrate_lifespan
       "tetrate:customer" = local.tetrate.tags.tetrate_customer
       "environment"      = var.name_prefix
  }
}