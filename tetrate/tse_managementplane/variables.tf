variable "name_prefix" {
  description = "name prefix"
}

variable "region" {
}

variable "k8s_cluster" {
  default = {
    cloud      = "aws"
    cluster_id = 0
  }
}

variable "tetrate" {
  type    = map
  default = {}
}

locals {
  tetrate_defaults = {
    fqdn                 = "demo"
    version              = "demo"
    password             = "Tetrate123"
    image_sync_username  = "demo"
    image_sync_apikey    = "demo"
    helm_repository      = "https://charts.dl.tetrate.io/public/helm/charts/"
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