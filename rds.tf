resource "aws_db_subnet_group" "production" {
	name = "production"
	subnet_ids = [
		"${aws_subnet.production-2a.id}",
		"${aws_subnet.production-2b.id}"
	]
}

resource "aws_db_instance" "production" {
	allocated_storage = 5
	storage_type = "gp2"
	engine = "mariadb"
	engine_version = "10.1.23"
	instance_class = "db.t2.micro"
	name = "production"
	username = "ollie"
	password = "ajfkljashdflkajshdfxvnbbqp"
	backup_retention_period = 0
	db_subnet_group_name = "${aws_db_subnet_group.production.name}"
	vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
	skip_final_snapshot = true
}
