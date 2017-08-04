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
		"${aws_subnet.production-2a.id}",
		"${aws_subnet.production-2b.id}"
	]
}

resource "aws_launch_configuration" "ecs_production" {
	name = "ECS production"
	image_id = "ami-ff15039b"
	instance_type = "t2.micro"
	associate_public_ip_address = true
	key_name = "ollie"
	iam_instance_profile = "${aws_iam_instance_profile.ecs_host_profile.id}"
	security_groups = ["${aws_security_group.allow_all.id}"]
	user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=production >>/etc/ecs/ecs.config
EOF
}
