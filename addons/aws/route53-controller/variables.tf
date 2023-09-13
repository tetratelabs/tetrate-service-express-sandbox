variable "cluster_id" {
}

variable "region" {
}

variable "k8s_cluster" {
  default = {
    cloud = "aws"
  }
}