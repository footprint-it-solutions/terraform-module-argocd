data "aws_iam_policy_document" "ecr_trust_policy" {
  count = var.create_ecr_iam_role ? 1 : 0
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values = [
        "system:serviceaccount:argocd:ecr-credential-provider"
      ]
    }

    principals {
      type = "Federated"
      identifiers = [
        var.oidc_provider_arn
      ]
    }
  }
}

resource "aws_iam_role" "ecr_iam_role" {
  count = var.create_ecr_iam_role ? 1 : 0
  # This role will be used by the ECR credential provider SA to create ECRAuthorizationToken object
  # Externalsecrets will create Argo repository secret using this token
  name               = "ecr-credential-provider"
  assume_role_policy = data.aws_iam_policy_document.ecr_trust_policy[0].json
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attachement" {
  count = var.create_ecr_iam_role ? 1 : 0
  role       = aws_iam_role.ecr_iam_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}
