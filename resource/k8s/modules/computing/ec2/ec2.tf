################################################  app server #####################################
resource "aws_instance" "appserver" {
availability_zone = "us-east-1a"
ami = "${var.myamiid}"
instance_type = "t2.medium"
subnet_id = "${var.public-subnet}"
private_ip= "192.168.1.6"
vpc_security_group_ids = ["${var.appsg}"]
key_name = "${var.mykeypair}"
  tags = {
    Name = "appserver"
  }
}


################################### db server #####################################
resource "aws_instance" "dbserver" {
availability_zone = "us-east-1b"
ami = "${var.myamiid}"
instance_type = "t2.medium"
subnet_id = "${var.private-subnet}"
private_ip= "192.168.2.6"
vpc_security_group_ids = ["${var.dbsg}"]
key_name = "${var.mykeypair}"
  tags = {
    Name = "dbserver"
  }
}
