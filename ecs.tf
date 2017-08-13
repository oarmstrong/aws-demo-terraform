resource "aws_ecs_cluster" "production" {
	name = "production"
}

resource "aws_autoscaling_group" "ecs_production" {
	name = "ECS production"
	min_size = 3
	max_size = 5
	desired_capacity = 3
	health_check_type = "EC2"
	launch_configuration = "${aws_launch_configuration.ecs_production.name}"
	vpc_zone_identifier = [
		"${aws_subnet.production-1a.id}",
		"${aws_subnet.production-1b.id}"
	]
}

data "template_file" "ecs_production_user_data" {
  template ="${file("user-data/ecs_production")}"
  vars {
    efs_id = "${aws_efs_file_system.production.id}"
  }
}
resource "aws_launch_configuration" "ecs_production" {
	name = "ECS production"
	image_id = "ami-809f84e6"
	instance_type = "t2.micro"
	associate_public_ip_address = true
	key_name = "ollie"
	iam_instance_profile = "${aws_iam_instance_profile.ecs_host_profile.id}"
	security_groups = ["${aws_security_group.allow_all.id}"]
	user_data = "${data.template_file.ecs_production_user_data.rendered}"
}

resource "aws_efs_file_system" "production" {
  creation_token = "production"
}

resource "aws_efs_mount_target" "production-1a" {
  file_system_id = "${aws_efs_file_system.production.id}"
  subnet_id = "${aws_subnet.production-1a.id}"
  security_groups = ["${aws_security_group.allow_all.id}"]
}

resource "aws_efs_mount_target" "production-1b" {
  file_system_id = "${aws_efs_file_system.production.id}"
  subnet_id = "${aws_subnet.production-1b.id}"
  security_groups = ["${aws_security_group.allow_all.id}"]
}
