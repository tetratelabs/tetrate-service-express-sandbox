variable "name_prefix" {
  type        = string
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
  type        = string
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