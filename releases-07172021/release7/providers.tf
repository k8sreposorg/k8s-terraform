provider "aws" {
  region = "${var.myregion}"
  shared_credentials_file = "/home/centos/.aws/credentials"
}

