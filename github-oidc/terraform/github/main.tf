module "github_oidc" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
}

data "aws_iam_policy_document" "github_actions_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["${module.github_oidc.arn}"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_org}/${var.github_repo}:*",
        "repo:${var.github_org}/${var.github_repo}-lambda:*"
        
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_inline_policy" {
  statement {
    actions = [
      "dynamodb:*",
      "ec2:*",
      "ecr:*",
      "eks:*",
      "iam:*",
      "logs:*",
      "kms:*",
      "s3:*",
      "ecr:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = "github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_policy.json

  inline_policy {
    name   = "github-actions-inline-policy"
    policy = data.aws_iam_policy_document.github_actions_inline_policy.json
  }
}