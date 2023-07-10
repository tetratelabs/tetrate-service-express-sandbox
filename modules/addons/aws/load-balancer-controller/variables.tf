variable "cluster_name" {
}

variable "k8s_host" {
}

variable "k8s_cluster_ca_certificate" {
}

variable "k8s_client_token" {
}

variable "oidc_provider_arn" {
  default = ""
}

variable "cluster_oidc_issuer_url" {
  default = ""
}

variable "helm_chart_version" {
  default = "1.5.4"
}