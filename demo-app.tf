resource "aws_elb" "demo-app" {
	name = "demo-app"
	security_groups = ["${aws_security_group.allow_all.id}"]
	subnets = [
		"${aws_subnet.production-2a.id}",
		"${aws_subnet.production-2b.id}"
	]

	listener {
		lb_protocol = "http"
		lb_port = "80"

		instance_protocol = "http"
		instance_port = "8080"
	}

	health_check {
		healthy_threshold = 3
		unhealthy_threshold = 2
		target = "HTTP:8080/"
		interval = 5
		timeout = 2
	}
}

resource "aws_route53_record" "demo-app" {
	zone_id = "${aws_route53_zone.primary.zone_id}"
	name = "demo.aws.oarmstrong.us"
	type = "A"

	alias {
		name = "${aws_elb.demo-app.dns_name}"
		zone_id = "${aws_elb.demo-app.zone_id}"
		evaluate_target_health = true
	}
}

data "template_file" "demo-app-definition" {
  template = "${file("task-definitions/demo-app.json")}"
  vars {
    mysql_endpoint = "${aws_db_instance.production.address}"
  }
}

resource "aws_ecs_task_definition" "demo-app" {
	family = "demo-app"
	container_definitions = "${template_file.demo-app-definition.rendered}"
}

resource "aws_ecs_service" "demo-app" {
	name = "demo-app"
	cluster = "${aws_ecs_cluster.production.id}"
	task_definition = "${aws_ecs_task_definition.demo-app.arn}"
	iam_role = "${aws_iam_role.ecs_service_role.arn}"
	desired_count = 2
	deployment_minimum_healthy_percent = 50
	depends_on = ["aws_iam_role_policy.ecs_service_role_policy"]

	load_balancer {
		elb_name = "${aws_elb.demo-app.id}"
		container_name = "demo-app-http"
		container_port = "80"
	}
}

// Codebuild
resource "aws_codebuild_project" "demo-app" {
	name = "demo-app"
	build_timeout = 5
	service_role = "${aws_iam_role.codebuild-role.arn}"

	artifacts {
		type = "NO_ARTIFACTS"
	}

	environment {
		compute_type = "BUILD_GENERAL1_SMALL"
		image = "aws/codebuild/docker:1.12.1"
		type = "LINUX_CONTAINER"
		privileged_mode = true
	}

	source {
		type = "GITHUB"
		location = "https://github.com/oarmstrong/aws-demo-app.git"
	}
}
