module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }
  }

  create_kms_key = false

  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }

    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.additional.id
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.additional.id
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                              = var.ami_type
    attach_cluster_primary_security_group = true
    instance_types                        = var.eks_mananged_node_instance_types
    vpc_security_group_ids                = [aws_security_group.additional.id]

    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  eks_managed_node_groups = {
    node_group_one = {
      min_size     = var.node_group_one_min_size
      max_size     = var.node_group_one_max_size
      desired_size = var.node_group_one_desired_size

      instance_types = var.node_group_one_instance_types
      capacity_type  = var.node_group_one_capacity_type

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }

      update_config = {
        max_unavailable_percentage = var.node_group_one_max_unavail_percentage
      }
    }
  }

  tags = local.tags
}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = "separate-eks-mng"
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,
  ]

  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }


  ami_type = "BOTTLEROCKET_x86_64"
  platform = "bottlerocket"

  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"
  EOT

  tags = merge(local.tags, { Separate = "eks-managed-node-group" })
}

resource "local_file" "config" {
  content = templatefile("${path.module}/kubeconfig.tftpl",
    {
      aws_region       = var.aws_region
      cluster_arn      = module.eks.cluster_arn
      cluster_cert     = module.eks.cluster_certificate_authority_data
      cluster_endpoint = module.eks.cluster_endpoint
      name             = var.cluster_context_name

    }
  )
  filename = "${var.kubeconfig_destination}.yaml"
}
