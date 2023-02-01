output "oidc_arn" {
  value = module.github_oidc.arn
}

output "oidc_url" {
  value = module.github_oidc.url
}

output "role_arn" {
  value = aws_iam_role.github_actions_role.arn
}

output "inline_policy" {
  value = data.aws_iam_policy_document.github_actions_inline_policy.json
}

output "assume_policy" {
  value = data.aws_iam_policy_document.github_actions_assume_policy.json
}