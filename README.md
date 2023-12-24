https://learn.hashicorp.com/tutorials/terraform/eks

Project Title
=====================
Terraform is used to provision and manage IT Infrastructure

Pre-Requisites
============================
Step 1: Install AWS CLI

sudo yum install git -y && sudo yum install wget -y && sudo yum install unzip -y

sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo unzip awscliv2.zip

sudo ./aws/install

Step 2: Install kubectl

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"


Execution Flow
=====================

$git clone https://github.com/cloudstones/k8s-terraform.git

$cd k8s-terratform/src

$vi config.json 

$terraform init .

$terraform validate -var-file=config.json .

$terraform apply -var-file=config.json .

configure kubectl

$aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

or

 aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name myeks --alias myeks


# Issues
if elb not able to launch then add the below to Public subnets as TAg : https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/

kubernetes.io/cluster/<EKS_CLUSTER_NAME> : shared

https://stackoverflow.com/questions/62468996/eks-could-not-find-any-suitable-subnets-for-creating-the-elb


https://aws.amazon.com/premiumsupport/knowledge-center/public-load-balancer-private-ec2/

terraform apply -var-file=config.json .

issue :Error: Get "http://localhost/api/v1/namespaces/kube-system/configmaps/aws-auth": dial tcp [::1]:80: connect: connection refused

Solution: terraform state rm module.eks.kubernetes_config_map.aws_auth

Reference: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/911


