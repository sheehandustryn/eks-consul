locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  name     = var.cluster_context_name
  vpc_cidr = "10.0.0.0/16"

  tags = {
    GithubRepo = "interview-exercise"
    GithubOrg  = "sheehandustryn"
  }
}
