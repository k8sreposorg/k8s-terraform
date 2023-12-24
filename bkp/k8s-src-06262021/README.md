https://learn.hashicorp.com/tutorials/terraform/eks

Project Title
=====================
Terraform is used to provision and manage IT Infrastructure

Pre-Requisites
============================



Execution Flow
=====================

$git clone https://github.com/cloudstones/k8s-terraform.git

$cd k8s-terratform/src

chnage custome AMI in worker.tf file

$vi modules/containers/eks/workers.tf

image_id =""

$vi k8s-terratform/src/config.json 

"myregion" : "",

$terraform init .

$terraform validate -var-file=config.json .

$terraform apply -var-file=config.json .

configure kubectl

$aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
