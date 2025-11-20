terraform {
  required_providers {
    helm       = {}
    kubernetes = {}
  }
}

data "aws_ssm_parameter" "argocd_github_app_private_key" {
  name = "/argocd/github-app/private-key"
}
data "aws_ssm_parameter" "argocd_repo_k8s_resources" {
  name = "/argocd/github-app/k8s-resources"
}

data "aws_ssm_parameter" "google_sso_oauth_client_id" {
  name = "/argocd/google-oauth/client-id"
}

data "aws_ssm_parameter" "google_sso_oauth_client_secret" {
  name = "/argocd/google-oauth/client-secret"
}

locals {
  client_id                          = data.aws_ssm_parameter.google_sso_oauth_client_id.value
  client_secret                      = base64encode(data.aws_ssm_parameter.google_sso_oauth_client_secret.value)
  repo_k8s_resources_app_id          = jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).githubAppID
  repo_k8s_resources_app_install_id  = jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).githubAppInstallationID
  repo_k8s_resources_app_private_key = base64encode(data.aws_ssm_parameter.argocd_github_app_private_key.value)
  repo_k8s_resources_project         = jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).project
  repo_k8s_resources_type            = jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).type
}

resource "helm_release" "secrets" {
  provider         = helm
  name             = "secrets"
  chart            = "${path.module}/helm-charts/secrets"
  namespace        = var.argocd_namespace
  create_namespace = true

  set = [
    {
      name  = "awsAccountId"
      value = var.aws_account_id
    },
    {
      name  = "awsRegion"
      value = var.aws_region
    },
    {
      name  = "domain"
      value = var.domain
    },
    {
      name  = "efsFileSystemId"
      value = var.efs_file_system_id
    },
    {
      name  = "environmentName"
      value = var.environment_name
    },
    {
      name  = "gitopsRepo"
      value = var.gitops_repo
    },
    {
      name  = "kmsKeyArn"
      value = var.kms_key_arn
    },
    {
      name  = "nodeSecurityGroupId"
      value = var.node_security_group_id
    },
    {
      name  = "oauth.clientID"
      value = local.client_id
    },
    {
      name      = "oauth.clientSecret"
      value     = local.client_secret
      sensitive = true
    },
    {
      name  = "oidcProvider"
      value = var.oidc_provider
    },
    {
      name      = "repo.k8s_resources.githubAppPrivateKey"
      value     = local.repo_k8s_resources_app_private_key
      sensitive = true
    },
    {
      name  = "repo.k8s_resources.githubAppID"
      value = local.repo_k8s_resources_app_id
    },
    {
      name  = "repo.k8s_resources.githubAppInstallationID"
      value = local.repo_k8s_resources_app_install_id
    },
    {
      name  = "repo.k8s_resources.name"
      value = "repo-1945554048"
    },
    {
      name  = "repo.k8s_resources.project"
      value = local.repo_k8s_resources_project
    },
    {
      name  = "repo.k8s_resources.type"
      value = local.repo_k8s_resources_type
    },
    {
      name  = "repo.k8s_resources.url"
      value = var.gitops_repo
    },
    {
      name  = "vpcCidr"
      value = var.vpc_cidr
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]
}

resource "helm_release" "argocd" {
  provider   = helm
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = var.argocd_namespace
  repository = "https://argoproj.github.io/argo-helm"
  timeout    = 420
  version    = var.argocd_version

  depends_on = [
    helm_release.secrets
  ]

  set = [
    {
      name  = "controller.replicas"
      value = "2"
    },
    {
      name  = "controller.resources.limits.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.limits.memory"
      value = "4Gi"
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.requests.memory"
      value = "2048Mi"
    },
    {
      name  = "global.domain"
      value = "argocd.${var.domain}"
    }
  ]

  values = [
    "${file("${path.module}/values.yaml")}"
  ]
}

resource "helm_release" "core_apps" {
  count     = var.gitops_repo != "" ? 1 : 0
  provider  = helm
  name      = "core-apps"
  chart     = "${path.module}/helm-charts/core-apps"
  namespace = var.argocd_namespace

  depends_on = [
    helm_release.argocd
  ]

  set = [
    {
      name  = "gitopsRepo"
      value = var.gitops_repo
    }
  ]
}
