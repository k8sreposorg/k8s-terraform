output "appserver" {
value = "${aws_instance.appserver.id}"
}
output "dbserver" {
value = "${aws_instance.dbserver.id}"
}
output "appserver_publicip" {
value = "${aws_instance.appserver.public_ip}"
}
