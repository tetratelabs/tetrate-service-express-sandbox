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

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
    token                  = var.k8s_client_token
  }
}

resource "aws_route53_zone" "cluster" {
  name = "${var.cluster_name}.${var.dns_zone}"
  tags = merge(var.tags, {
    Name = "${var.cluster_name}.${var.dns_zone}"
  })
}

data "aws_route53_zone" "shared" {
  name = var.dns_zone
}

resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.shared.zone_id
  name    = aws_route53_zone.cluster.name
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.cluster.name_servers
}

resource "aws_iam_policy" "policy_service_account" {
  name        = "${var.cluster_name}-AllowRoute53Updates"
  description = "Policy for service account in ${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets"
        ],
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "role_service_account" {
    name = "${var.cluster_name}-iamserviceaccount-r53"
    assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement" : [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "${var.oidc_provider_arn}"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "${var.cluster_oidc_id}:aud": "sts.amazonaws.com",
                        "${var.cluster_oidc_id}:sub": "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
                    }
                }
            }
        ]
    }
POLICY
}

resource "aws_iam_role_policy_attachment" "policy_attachment_service_account" {
  policy_arn = aws_iam_policy.policy_service_account.arn
  role       = aws_iam_role.role_service_account.name
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = var.service_account_namespace
  }
  # lifecycle {
  #   prevent_destroy = true
  # }
}


resource "kubernetes_service_account" "service_account" {
    metadata {
        name = "${var.service_account_name}"
        annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.role_service_account.arn
        }
        namespace = var.service_account_namespace
    }

}

resource "local_file" "aws_cleanup" {
  content = templatefile("${path.module}/external-dns_aws_cleanup.sh.tmpl", {
    cluster_name = "${var.cluster_name}"
})
  filename        = "${var.output_path}/${var.cluster_name}-external-dns-aws-cleanup.sh"
  file_permission = "0755"
}

# resource "local_file" "aws_cleanup" {
#   content = templatefile("${path.module}/external-dns_aws_cleanup.sh.tmpl", {
#     name_prefix = "eks-${regex(".+-", var.name_prefix)}"
#   })
#   filename        = "${var.output_path}/${var.name_prefix}-external-dns-aws-cleanup.sh"
#   file_permission = "0755"
# }

resource "null_resource" "aws_cleanup" {
  triggers = {
    output_path = var.output_path
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "sh ${self.triggers.output_path}/${self.triggers.cluster_name}-external-dns-aws-cleanup.sh"
    on_failure = continue
  }

  depends_on = [local_file.aws_cleanup, aws_route53_zone.cluster]
}