variable "name_prefix" {
  description = "name prefix"
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
    password            = "tse"
    image_sync_username = "demo"
    image_sync_apikey   = "demo"
    helm_repository     = "https://charts.tse.tetrate.io/public/helm/charts"
  }
  tetrate = merge(local.tetrate_defaults, var.tetrate)
}