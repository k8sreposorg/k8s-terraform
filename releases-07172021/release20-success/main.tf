################# Importing  VPC module    ##########################
module "vpc" {
  source  = "./modules/networking/vpc"
}
################# Importing  Security module    ##########################
module "security" {
  source  = "./modules/security/"
  vpc_id = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
}

####################### Importing EKS module ################################
module "eks" {
  source          = "./modules/containers/eks"
  cluster_name    = "myeks"
  cluster_version = "1.18"
  vpc_id = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  iam-instance-profile-for-workers = module.security.iam-instance-profile-for-workers
  iam-role-arn-for-cluster  = module.security.iam-role-arn-for-cluster
  iam-role-name-for-workers = module.security.iam-role-name-for-workers
  masters-sg = module.security.masters-sg
  workers-sg = module.security.workers-sg
  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}
