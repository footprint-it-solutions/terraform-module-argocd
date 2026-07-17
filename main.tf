terraform {
  required_providers {
    helm       = {}
    kubernetes = {}
    local      = {}
  }
}

data "aws_ssm_parameter" "argocd_github_app_private_key" {
  name = "/argocd/github-app/private-key"
}
data "aws_ssm_parameter" "argocd_repo_k8s_resources" {
  name = "/argocd/github-app/k8s-resources"
}

data "aws_ssm_parameter" "google_oauth_client_id" {
  count = var.enable_google_oauth ? 1 : 0
  name  = "/argocd/google-oauth/client-id"
}

data "aws_ssm_parameter" "google_oauth_client_secret" {
  count = var.enable_google_oauth ? 1 : 0
  name  = "/argocd/google-oauth/client-secret"
}

locals {
  client_id                          = nonsensitive(var.enable_google_oauth ? data.aws_ssm_parameter.google_oauth_client_id[0].value : "")
  client_secret                      = var.enable_google_oauth ? base64encode(data.aws_ssm_parameter.google_oauth_client_secret[0].value) : ""
  repo_k8s_resources_app_id          = nonsensitive(jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).githubAppID)
  repo_k8s_resources_app_install_id  = nonsensitive(jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).githubAppInstallationID)
  repo_k8s_resources_app_private_key = base64encode(data.aws_ssm_parameter.argocd_github_app_private_key.value)
  repo_k8s_resources_project         = nonsensitive(jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).project)
  repo_k8s_resources_type            = nonsensitive(jsondecode(data.aws_ssm_parameter.argocd_repo_k8s_resources.value).type)
}

resource "helm_release" "secrets" {
  provider         = helm
  name             = "secrets"
  chart            = "${path.module}/helm-charts/secrets"
  namespace        = var.argocd_namespace
  create_namespace = true

  set_sensitive = [{
    name  = "oauth.clientSecret"
    value = local.client_secret
    }, {
    name  = "repo.k8s_resources.githubAppPrivateKey"
    value = local.repo_k8s_resources_app_private_key
  }]

  values = [<<EOF
---
awsAccountId: "${var.aws_account_id}"
awsRegion: ${var.aws_region}
domain: ${var.domain}
efsFileSystemId: ${var.efs_file_system_id}
environmentName: ${var.environment_name}
gitopsRepo: ${var.gitops_repo}
kmsKeyArn: ${var.kms_key_arn}
nodeSecurityGroupId: ${var.node_security_group_id}
oauth:
  clientID: "${local.client_id}"
oidcProvider: ${var.oidc_provider}
repo:
  k8s_resources:
    githubAppID: "${local.repo_k8s_resources_app_id}"
    githubAppInstallationID: "${local.repo_k8s_resources_app_install_id}"
    name: repo-1945554048
    project: ${local.repo_k8s_resources_project}
    type: ${local.repo_k8s_resources_type}
    url: ${var.gitops_repo}
gitopsRef: ${var.gitops_ref}
vpcCidr: ${var.vpc_cidr}
vpcId: ${var.vpc_id}
  EOF
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

  values = [
    templatefile("${path.module}/values.yaml", {
      application_controller_qps       = var.argocd_application_controller_qps
      application_controller_replicas  = var.argocd_application_controller_replicas
      application_controller_cpu_lim   = var.argocd_application_controller_resources.limits.cpu
      application_controller_mem_lim   = var.argocd_application_controller_resources.limits.memory
      application_controller_cpu_req   = var.argocd_application_controller_resources.requests.cpu
      application_controller_mem_req   = var.argocd_application_controller_resources.requests.memory
      applicationset_replicas          = var.argocd_applicationset_replicas
      applicationset_cpu_lim           = var.argocd_applicationset_resources.limits.cpu
      applicationset_mem_lim           = var.argocd_applicationset_resources.limits.memory
      applicationset_cpu_req           = var.argocd_applicationset_resources.requests.cpu
      applicationset_mem_req           = var.argocd_applicationset_resources.requests.memory
      redis_ha_enabled                 = var.argocd_redis_ha_enabled
      repo_server_autoscaling_enabled  = var.argocd_repo_server_autoscaling_enabled
      repo_server_max_replicas         = var.argocd_repo_server_max_replicas
      repo_server_min_replicas         = var.argocd_repo_server_min_replicas
      repo_server_cpu_lim              = var.argocd_repo_server_resources.limits.cpu
      repo_server_mem_lim              = var.argocd_repo_server_resources.limits.memory
      repo_server_cpu_req              = var.argocd_repo_server_resources.requests.cpu
      repo_server_mem_req              = var.argocd_repo_server_resources.requests.memory
      server_autoscaling_enabled       = var.argocd_server_autoscaling_enabled
      server_max_replicas              = var.argocd_server_max_replicas
      server_min_replicas              = var.argocd_server_min_replicas
      server_cpu_lim                   = var.argocd_server_resources.limits.cpu
      server_mem_lim                   = var.argocd_server_resources.limits.memory
      server_cpu_req                   = var.argocd_server_resources.requests.cpu
      server_mem_req                   = var.argocd_server_resources.requests.memory
    }),
    var.values_override,
    <<EOF
---
global:
  domain: argocd.${var.domain}
    EOF
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

  values = [
    <<EOF
---
gitopsRepo: ${var.gitops_repo}
gitopsRef: ${var.gitops_ref}
    EOF
  ]
}
