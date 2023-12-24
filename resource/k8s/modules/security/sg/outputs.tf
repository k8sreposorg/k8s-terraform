output "appsg" {
value = "${aws_security_group.appsg.id}"
}
output "dbsg" {
value = "${aws_security_group.dbsg.id}"
}
