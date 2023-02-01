provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

locals {
  aws_auth_node_iam_role_arns_non_windows = [
    module.eks.eks_managed_node_groups.node_group_one.iam_role_arn
  ]

  aws_auth_roles = [
    {
      rolearn  = module.eks.eks_managed_node_groups.node_group_one.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
    {
      rolearn  = var.aws_role_arn
      username = var.aws_user_name
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = var.aws_user_arn
      username = var.aws_user_name
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [
    var.aws_account_id
  ]


  node_iam_role_arns_non_windows = distinct(
    compact(
      concat(
        [for group in module.eks.eks_managed_node_groups : group.iam_role_arn],
        local.aws_auth_node_iam_role_arns_non_windows
      )
    )
  )

  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      [for role_arn in local.node_iam_role_arns_non_windows : {
        rolearn  = role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
        }
      ],
      local.aws_auth_roles
    ))
    mapUsers    = yamlencode(local.aws_auth_users)
    mapAccounts = yamlencode(local.aws_auth_accounts)
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = 1

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data
}
