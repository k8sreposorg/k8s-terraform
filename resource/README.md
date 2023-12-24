https://learn.hashicorp.com/tutorials/terraform/eks

Project Title
=====================
Terraform is used to provision and manage IT Infrastructure

Pre-Requisites
============================



Execution Flow
=====================

$git clone https://github.com/cloudstones/k8s-terraform.git

$cd k8s-terratform/k8s

$vi config.json

{

"myregion" : "us-east-1",

"myamiid" : "",

"mykeypair" : "",

}

$aws configure

$terraform init .

$terraform validate -var-file=config.json .

$terraform apply -var-file=config.json .
