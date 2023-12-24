################# Importing  VPC module    ##########################
module "vpc" {
  source  = "./modules/networking/vpc"
}

####################### Importing EKS module ################################
module "eks" {
  source          = "./modules/containers/eks"
  cluster_name    = "myeks"
  cluster_version = "1.18"
  vpc_id = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}
