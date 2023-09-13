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

resource "kubernetes_service_account" "service_account" {
    metadata {
        name = "${var.service_account_name}"
        annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.role_service_account.arn
        }
        namespace = var.service_account_namespace
    }

}

resource "null_resource" "helm_upgrade" {
  triggers = {
    kubectl_apply_trigger = kubernetes_service_account.service_account.id
  }

  provisioner "local-exec" {
    command = <<EOT
      helm get values tse-cp -n istio-system > cp-values.yaml
      helm upgrade tse-cp tse/controlplane \
        -n istio-system -f cp-values.yaml \
        --set spec.providerSettings.route53.serviceAccountName=route53-controller \
        --set "spec.providerSettings.route53.domainFilter={*.aws-ce.sandbox.tetrate.io}
    EOT
  }
}

#helm upgrade controlplane tse/controlplane \
#  -n istio-system -f cp-values.yaml \
#  --set spec.providerSettings.route53.serviceAccountName=route53-controller \
#  --set "spec.providerSettings.route53.domainFilter={*.aws-ce.sandbox.tetrate.io}"