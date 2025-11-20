data "aws_iam_policy_document" "trust_policy" {
  count = var.multi_cluster ? 1 : 0
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
        "system:serviceaccount:argocd:argocd-application-controller",
        "system:serviceaccount:argocd:argocd-server",
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

resource "aws_iam_role" "this" {
  count              = var.multi_cluster ? 1 : 0
  name               = "argocd-management"
  assume_role_policy = data.aws_iam_policy_document.trust_policy[0].json
}

data "aws_iam_policy_document" "this" {
  count = var.multi_cluster ? 1 : 0
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/argocd"
    ]
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "this" {
  count  = var.multi_cluster ? 1 : 0
  name   = "argocd-management"
  policy = data.aws_iam_policy_document.this[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.multi_cluster ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
