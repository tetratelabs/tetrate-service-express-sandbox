variable "name_prefix" {
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

variable "k8s_cluster" {
  default = {
    cloud = "aws"
  }
}

variable "jumpbox_username" {
  default = "tetrate-admin"
}

variable "output_path" {
  default = "../../outputs"
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