output "cloudstones-vpc" {
value = "${aws_vpc.cloudstones-vpc.id}"
}
output "public-subnet" {
value = "${aws_subnet.public-subnet.id}"
}
output "private-subnet" {
value = "${aws_subnet.private-subnet.id}"
}
