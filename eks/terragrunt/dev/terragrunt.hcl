terraform {
  source = "../..//terraform/cluster"
}

locals {
  arn         = yamldecode(sops_decrypt_file("arn.enc.yaml"))
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

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
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
    key            = "eks/terraform.tfstate"
    region         = "${local.common_vars.aws_region}"
  }
}

inputs = {
  ami_type                              = "${local.dev_vars.ami_type}"
  aws_account_id                        = "${local.dev_vars.aws_account_id}"
  aws_region                            = "${local.common_vars.aws_region}"
  aws_role_arn                          = "${local.arn.aws_role_arn}"
  aws_user_arn                          = "${local.arn.aws_user_arn}"
  aws_user_name                         = "${local.arn.aws_user_name}"
  cluster_context_name                  = "${local.common_vars.cluster_context_name}"
  eks_managed_node_instance_types       = "${local.dev_vars.eks_managed_node_instance_types}"
  kubeconfig_destination                = "${local.common_vars.kubeconfig_destination}"
  min_healthy_percentage                = "${local.dev_vars.min_healthy_percentage}"
  node_group_one_capacity_type          = "${local.dev_vars.node_group_one_capacity_type}"
  node_group_one_desired_size           = "${local.dev_vars.node_group_one_desired_size}"
  node_group_one_instance_types         = "${local.dev_vars.node_group_one_instance_types}"
  node_group_one_max_size               = "${local.dev_vars.node_group_one_max_size}"
  node_group_one_max_unavail_percentage = "${local.dev_vars.node_group_one_max_unavail_percentage}"
  node_group_one_min_size               = "${local.dev_vars.node_group_one_min_size}"
  spot_instance_type                    = "${local.dev_vars.spot_instance_type}"
}
