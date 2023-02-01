variable "ami_type" {
  type        = string
  description = "The type of AWS AMI to use"
}

variable "aws_account_id" {
  description = "The id of the AWS account in which resources are being deployed."
  type        = string
}

variable "aws_region" {
  type        = string
  description = "The AWS region in which to deploy resources"
}

variable "aws_role_arn" {
  description = "The ARN of the AWS Role to configure in kubeconfig"
  type        = string
}

variable "aws_user_arn" {
  description = "The arn of the user that will be used by the kubeconfig to interact with the cluster"
  type        = string
}

variable "aws_user_name" {
  description = "The name of the user that will be used by the kubeconfig to interact with the cluster"
  type        = string
}

variable "cluster_context_name" {
  description = "The name to use for the cluster in the generated kubeconfig"
  type        = string
}

variable "eks_mananged_node_instance_types" {
  type        = list(string)
  description = "A List of AWS instance types to use for the eks managed nodes"
  default     = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]

}

variable "kubeconfig_destination" {
  type        = string
  description = "The full path to use for the generated kubeconfig file"
}

variable "min_healthy_percentage" {
  type        = number
  description = "The percentage of nodes that must be healthy"
  default     = 66
}

variable "node_group_one_capacity_type" {
  type    = string
  default = "SPOT"

}

variable "node_group_one_desired_size" {
  type        = number
  description = "The starting number of nodes in node group one"
  default     = 1
}

variable "node_group_one_instance_types" {
  type        = list(string)
  description = "The AWS instance type to use for node group one nodes"
  default     = ["t3.large"]
}

variable "node_group_one_max_size" {
  type        = number
  description = "The maximum allowed number of nodes in node group one"
  default     = 3
}

variable "node_group_one_max_unavail_percentage" {
  type        = number
  description = "The maximum percent of nodes that can be unavailable at the same time in node group one"
  default     = 33
}

variable "node_group_one_min_size" {
  type        = number
  description = "The minimum number of nodes to maintain in node group one"
  default     = 1
}

variable "spot_instance_type" {
  type        = string
  description = "The AWS instance type to use for SPOT instances"
  default     = "m5.large"
}
