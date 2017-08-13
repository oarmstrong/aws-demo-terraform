data "template_file" "demo-app-definition" {
  template = "${file("task-definitions/demo-app.json")}"
  vars {
    mysql_endpoint = "${aws_db_instance.production.address}"
  }
}

resource "aws_ecs_task_definition" "demo-app" {
	family = "demo-app"
	container_definitions = "${data.template_file.demo-app-definition.rendered}"

  volume {
    name = "demo-app-uploads"
    host_path = "/efs/demo-app/uploads"
  }
}

resource "aws_alb" "demo-app" {
  name = "demo-app"
  security_groups = ["${aws_security_group.allow_all.id}"]
  internal = false
  subnets = [
    "${aws_subnet.production-1a.id}",
    "${aws_subnet.production-1b.id}"
  ]
}

output "demo-app-dns" {
  value = "${aws_alb.demo-app.dns_name}"
}

resource "aws_alb_target_group" "demo-app" {
  name = "demo-app"
  protocol = "HTTP"
  port = 80
  vpc_id = "${aws_vpc.production.id}"
}

resource "aws_alb_listener" "demo-app" {
  load_balancer_arn = "${aws_alb.demo-app.arn}"
  port = "80"
  protocol = "HTTP"

  default_action = {
    target_group_arn = "${aws_alb_target_group.demo-app.arn}"
    type = "forward"
  }
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
    target_group_arn = "${aws_alb_target_group.demo-app.arn}"
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
