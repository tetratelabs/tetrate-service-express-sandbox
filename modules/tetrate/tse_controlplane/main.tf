provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
    token                  = var.k8s_client_token
  }
}

provider "kubectl" {
  host                   = var.k8s_host
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  token                  = var.k8s_client_token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = var.k8s_host
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  token                  = var.k8s_client_token
}

resource "null_resource" "jumpbox_tctl" {
  connection {
    host        = var.jumpbox_host
    type        = "ssh"
    agent       = false
    user        = var.jumpbox_username
    private_key = var.jumpbox_pkey
  }
  provisioner "file" {
    content = templatefile("${path.module}/manifests/tetrate/cluster.yaml.tmpl", {
      cluster_name = var.cluster_name
    })
    destination = "${var.cluster_name}-cluster.yaml"
  }
  provisioner "file" {
    content = templatefile("${path.module}/manifests/tctl/tctl-controlplane.sh.tmpl", {
      cluster_name                     = var.cluster_name
      tetrate_managementplane_hostname = var.tetrate_managementplane_hostname
      tetrate_password                 = var.tetrate_password
    })
    destination = "${var.cluster_name}-tctl-controlplane.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh ${var.cluster_name}-tctl-controlplane.sh"
    ]
  }

  # file-remote is not supported yet, https://github.com/hashicorp/terraform/issues/3379
  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -oIdentitiesOnly=yes -oUserKnownHostsFile=/dev/null -i ${var.output_path}/${var.name_prefix}-${var.cloud}-${var.jumpbox_username}.pem  ${var.jumpbox_username}@${var.jumpbox_host}:${var.cluster_name}-values.yaml ${var.output_path}/${var.cluster_name}-values.yaml"
  }
}

data "local_file" "helm_values" {
  filename   = "${var.output_path}/${var.cluster_name}-values.yaml"
  depends_on = [null_resource.jumpbox_tctl]
}

resource "helm_release" "controlplane" {
  name                = "controlplane"
  repository          = var.tetrate_helm_repository
  repository_username = var.tetrate_helm_repository_username
  repository_password = var.tetrate_helm_repository_password
  chart               = "controlplane"
  version             = var.tetrate_version
  namespace           = "istio-system"
  create_namespace    = true
  timeout             = 600
  values              = [data.local_file.helm_values.content]
  #dns_aws_zone        = var.external_dns_aws_dns_zone

  set {
    name  = "image.registry"
    value = var.registry
  }

# Conditional block for adding values related to external_dns_aws_dns_zone
  dynamic "set" {
    for_each = var.external_dns_aws_dns_zone != null ? [1] : []
    content {
      name  = "spec.providerSettings.route53.serviceAccountName"
      value = "${var.service_account_name}"
    }
  }

  # dynamic "set" {
  #   for_each = var.external_dns_aws_dns_zone != null ? [1] : []
  #   content {
  #     name  = "spec.providerSettings.route53.domainFilter"
  #     value = "${var.cluster_name}.${var.external_dns_aws_dns_zone}"
  #   }
  # }

  depends_on = [null_resource.jumpbox_tctl, data.local_file.helm_values]
}