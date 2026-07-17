variable "argocd_application_controller_qps" {
  description = "The rate limit (queries per second) for the ArgoCD Application Controller K8s client to prevent API rate limiting"
  type        = string
  default     = "500"
}

variable "argocd_application_controller_replicas" {
  description = "The number of replicas for the ArgoCD Application Controller"
  type        = number
  default     = 2
}

variable "argocd_application_controller_resources" {
  description = "Resource allocations (CPU and memory requests/limits) for the ArgoCD Application Controller"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "1"
      memory = "4Gi"
    }
    requests = {
      cpu    = "500m"
      memory = "2Gi"
    }
  }
}

variable "argocd_applicationset_replicas" {
  description = "The number of replicas for the ArgoCD ApplicationSet controller"
  type        = number
  default     = 2
}

variable "argocd_applicationset_resources" {
  description = "Resource allocations (CPU and memory requests/limits) for the ArgoCD ApplicationSet controller"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "1"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}

variable "argocd_namespace" {
  description = "Namespace to install ArgoCD"
  type        = string
}

variable "argocd_redis_ha_enabled" {
  description = "Whether to enable High Availability (HA) for Redis, which spawns a multi-node Redis cluster with Sentinel"
  type        = bool
  default     = true
}

variable "argocd_repo_server_autoscaling_enabled" {
  description = "Whether to enable autoscaling for the ArgoCD repo server"
  type        = bool
  default     = true
}

variable "argocd_repo_server_max_replicas" {
  description = "The maximum number of replicas for the ArgoCD repo server autoscaler"
  type        = number
  default     = 4
}

variable "argocd_repo_server_min_replicas" {
  description = "The minimum number of replicas for the ArgoCD repo server autoscaler"
  type        = number
  default     = 2
}

variable "argocd_repo_server_resources" {
  description = "Resource allocations (CPU and memory requests/limits) for the ArgoCD repo server"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "1"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}

variable "argocd_server_autoscaling_enabled" {
  description = "Whether to enable autoscaling for the ArgoCD API/UI server"
  type        = bool
  default     = true
}

variable "argocd_server_max_replicas" {
  description = "The maximum number of replicas for the ArgoCD API/UI server autoscaler"
  type        = number
  default     = 4
}

variable "argocd_server_min_replicas" {
  description = "The minimum number of replicas for the ArgoCD API/UI server autoscaler"
  type        = number
  default     = 2
}

variable "argocd_server_resources" {
  description = "Resource allocations (CPU and memory requests/limits) for the ArgoCD API/UI server"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "1"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}

variable "argocd_version" {
  description = "ArgoCD version"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "create_ecr_iam_role" {
  description = "Whether to create an IAM role that allows pulling from ECR"
  type        = bool
  default     = true
}

variable "domain" {
  description = "Domain name for this environment"
  type        = string
}

variable "efs_file_system_id" {
  description = "EFS file system ID"
  type        = string
}

variable "enable_google_oauth" {
  description = "Whether to enable Google OAuth SSO"
  type        = bool
  default     = false
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "gitops_repo" {
  description = "GitOps Repository URL"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS key ARN for the EKS cluster"
  type        = string
}

variable "multi_cluster" {
  description = "Whether this is a multi-cluster setup"
  type        = bool
  default     = false
}

variable "node_security_group_id" {
  description = "Node Security Group ID"
  type        = string
}

variable "oidc_provider" {
  description = "The OIDC provider"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The OIDC provider ARN"
  type        = string
}

variable "gitops_ref" {
  description = "The target revision (branch, tag, or commit SHA) for the ArgoCD application"
  type        = string
  default     = "main"
}

variable "values_override" {
  description = "Heredoc Helm values file to override the chart defaults"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR where the EKS cluster is deployed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}
