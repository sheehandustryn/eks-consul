terraform {
  source = "../..//terraform/ecr"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common-vars.yaml")))
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
  region  = "${local.common_vars.aws_region}"
}
EOF
}

remote_state {

  backend = "s3"

  config = {
    bucket         = "interview-exercise-dev-tf-state"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "ecr/terraform.tfstate"
    region         = "${local.common_vars.aws_region}"
  }
}

inputs = {
  repo_name = local.common_vars.repo_name
}
