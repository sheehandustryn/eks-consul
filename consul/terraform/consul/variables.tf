variable "cluster_endpoint" {
  description = "The AWS EKS cluster endpoint"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "The AWS EKS cluster certificate authority data"
  type        = string
}

variable "cluster_name" {
  description = "The AWS EKS cluster name"
  type        = string
}