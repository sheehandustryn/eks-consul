terraform {
  source = "../..//terraform/motivate"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common-vars.yaml")))
  dev_vars    = yamldecode(file("dev-vars.yaml"))
  secrets     = yamldecode(sops_decrypt_file("secrets.enc.yaml"))
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
  contents  = <<EOF
provider "aws" {
  region  = "${local.common_vars.aws_region}"
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", var.cluster_name]
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
    key            = "motivate/terraform.tfstate"
    region         = "${local.common_vars.aws_region}"
  }
}

inputs = {
  cluster_endpoint                   = local.secrets.cluster_endpoint
  cluster_certificate_authority_data = local.secrets.cluster_certificate_authority_data
  cluster_name                       = local.secrets.cluster_name
}