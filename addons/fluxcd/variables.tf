variable "cluster_id" {
}

variable "region" {
}

variable "k8s_cluster" {
  default = {
    cloud = "aws"
  }
}

variable "fluxcd_include_example_applications" {
  default = true
}