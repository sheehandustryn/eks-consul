terraform {
  source = "../../terraform//kms"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common-vars.yaml")))
  dev_vars    = yamldecode(file("dev-vars.yaml"))
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.47"
    }
  }

  required_version = "~> 1.3"
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  profile = "${local.dev_vars.aws_profile}"
  region  = "${local.common_vars.aws_region}"

  assume_role {
    role_arn = "${local.dev_vars.aws_role_arn}"
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "interview-exercise-dev-tf-state"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "kms/terraform.tfstate"
    region         = "${local.common_vars.aws_region}"
    role_arn       = "${local.dev_vars.aws_role_arn}"
  }
}

inputs = {
  alias       = "alias/${local.common_vars.description}"
  description = "${local.common_vars.description}"
}
