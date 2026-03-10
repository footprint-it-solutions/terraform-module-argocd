# Terraform module for ArgoCD

This module deploys ArgoCD into an EKS cluster.

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `additional_resource_customisations` | Additional ArgoCD resource customisations to merge with the default ones | `string` | `null` |
| `argocd_namespace` | Namespace to install ArgoCD | `string` | - |
| `argocd_version` | ArgoCD version | `string` | - |
| `domain` | Domain name for this environment | `string` | - |
| `environment_name` | The name of the environment | `string` | - |
| `gitops_repo` | GitOps Repository URL | `string` | `""` |
| `gitops_ref` | The target revision for the ArgoCD application | `string` | `"main"` |
| `values_override` | Heredoc Helm values file to override the chart defaults | `string` | `""` |
