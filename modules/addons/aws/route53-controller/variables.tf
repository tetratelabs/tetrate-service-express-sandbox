variable "name_prefix" {
}

variable "cluster_name" {
}

variable "output_path" {
}

variable "region" {
}

variable "vpc_id" {
}

variable "k8s_host" {
}

variable "k8s_cluster_ca_certificate" {
}

variable "k8s_client_token" {
}

variable "tags" {
  type = map(any)
}

variable "dns_zone" {
}

locals {
  dns_name  = var.dns_zone
  zone_name = replace(local.dns_name, ".", "-")
}

variable "oidc_provider_arn" {
  default = ""
}

variable "cluster_oidc_issuer_url" {
  default = ""
}

variable "cluster_oidc_id" {
  default = ""
}

variable "service_account_namespace" {
    type = string
    default = "istio-system"
    description = "Kubernetes name space where the service account shall be created"
}

variable "service_account_name" {
    type = string
    default = "route53-controller"
    description = "Name of Service Account in kubernetes cluster."
}