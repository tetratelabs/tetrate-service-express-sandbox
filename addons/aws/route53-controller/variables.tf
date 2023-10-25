variable "cluster_id" {
}

variable "name_prefix" {
}

variable "output_path" {
  default = "../../../outputs"
}

variable "region" {
}

variable "k8s_cluster" {
  default = {
    cloud = "aws"
  }
}

variable "tetrate" {
  type    = map(any)
  default = {}
}

locals {
  tetrate_defaults = {
    fqdn                = "demo"
    version             = "demo"
    password            = "Tetrate123"
    image_sync_username = "demo"
    image_sync_apikey   = "demo"
    helm_repository     = "https://charts.dl.tetrate.io/public/helm/charts/"
  }
  tetrate = merge(local.tetrate_defaults, var.tetrate)
}

variable "tags" {
  type    = map(any)
  default = {}
}

locals {
  tags = {
    "tetrate:owner"    = "demo"
    "tetrate:team"     = "demo"
    "tetrate:purpose"  = "demo"
    "tetrate:lifespan" = "demo"
    "tetrate:customer" = "demo"
    "environment"      = var.name_prefix
  }

  default_tags = merge(local.tags, var.tags)
}

variable "external_dns_aws_dns_zone" {
}

