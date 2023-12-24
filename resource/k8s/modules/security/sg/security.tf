###########################  Security group for appserver ########################
resource "aws_security_group" "appsg" {
  name        = "appsg"
  description = "Allow all traffic"
  vpc_id ="${var.cloudstones-vpc}"
  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "appsg"
  }
}



###########################  Security group for dbserver ########################
resource "aws_security_group" "dbsg" {
  name        = "dbsg"
  description = "Allow all traffic"
  vpc_id ="${var.cloudstones-vpc}"
  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dbsg"
  }
}
