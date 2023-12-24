
############################################ Elastic IPs ###############################
resource "aws_eip" "appeip"{
instance = "${var.appserver}"
}
resource "aws_eip" "ngweip"{
}


############################################ Cloudstones VPC ###############################

resource "aws_vpc" "cloudstones-vpc"{
cidr_block = "192.168.0.0/16"
tags ={
Name = "cloudstones-vpc"
}
}

############################################ Public Subnet ###############################
resource "aws_internet_gateway" "myigw"{
vpc_id = "${aws_vpc.cloudstones-vpc.id}"
tags={
Name = "myigw"
}
}


resource "aws_subnet" "public-subnet"{
availability_zone = "us-east-1a"
vpc_id = "${aws_vpc.cloudstones-vpc.id}"
cidr_block = "192.168.1.0/24"
tags={
Name = "public-subnet"
}
}

resource "aws_route_table" "publicrtb"{
vpc_id = "${aws_vpc.cloudstones-vpc.id}"
tags = {
Name = "publicrtb"
}
}

resource "aws_route" "publicrt"{
route_table_id = "${aws_route_table.publicrtb.id}"
destination_cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.myigw.id}"
}
 
resource "aws_route_table_association" "publicrtba"{
route_table_id = "${aws_route_table.publicrtb.id}"
subnet_id = "${aws_subnet.public-subnet.id}"
}


############################################ Private Subnet ###############################
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngweip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "ngw"
  }
}

resource "aws_subnet" "private-subnet"{
availability_zone = "us-east-1b"
vpc_id = "${aws_vpc.cloudstones-vpc.id}"
cidr_block = "192.168.2.0/24"
tags={
Name = "private-subnet"
}
}

resource "aws_route_table" "privatertb"{
vpc_id = "${aws_vpc.cloudstones-vpc.id}"
tags = {
Name = "privatertb"
}
}

resource "aws_route" "privatert"{
route_table_id = "${aws_route_table.privatertb.id}"
destination_cidr_block = "0.0.0.0/0"
gateway_id = "${aws_nat_gateway.ngw.id}"
}
resource "aws_route_table_association" "privatertba"{
route_table_id = "${aws_route_table.privatertb.id}"
subnet_id = "${aws_subnet.private-subnet.id}"
}
