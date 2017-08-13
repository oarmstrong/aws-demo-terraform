resource "aws_iam_user" "ollie" {
	name = "ollie"
	path = "/"
}

resource "aws_iam_user_policy_attachment" "ollie" {
	user = "${aws_iam_user.ollie.name}"
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "ecs_host_role" {
	name = "ecs_host_role"
	assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_host_role_policy" {
	name = "ecs_host_role_policy"
	role = "${aws_iam_role.ecs_host_role.id}"
	policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecs:StartTask",
	"ecr:BatchCheckLayerAvailability",
	"ecr:BatchGetImage",
	"ecr:GetDownloadUrlForLayer",
	"ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_host_profile" {
	name = "ecs_host_profile"
	path = "/"
	role = "${aws_iam_role.ecs_host_role.name}"
}

resource "aws_key_pair" "ollie" {
	key_name = "ollie"
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOWXb7gpgjZK4VzdIqXANlCpezZbhcZTYqAj5s9TCH3FBFgQWNaeQ8EGkkVdfNKcVwk66D3MWC/hJs5s/h0G8HHAx5eOAjBsepfXQyeoKocRF1109/91+F5Mk6XEaJCEQGnLJJTKu8pV00AxjnCzNwzoaONfevknpkMur3e6Cm9AXoA7yBbs1octGRHuCO9GD/RKklFx36M79l5M9aV3EGl1apNUNYUxWhMSKbEgHQK4rUt9HAjuAEMKiKMnjxax6WUo/d/2E0QjFSG3XDg9wZ1CF7p1soDuRz9bnqW3w2B3gPlRpDyQ6I2cfSDL8bKoXh5Lhsg6ruq5kPkfvoGHyPVaMWKD60MW5ugjToRsjQ2I0k58UhpFdcm/B85J62aeo1HQwDymJIFAj/HMDenj9DaqtM2vAA68Mk/SB5QTsPTH01K3j6IYwsM9xa3GqFWtv74il46Ws0VjSkxw+Au0kREo4jlMQ6e/CgIgi7OTxfKgctHLR1zvhFLbd25rawTNvMS3sfF8B65/WiMqg8HW2fZ2ymcHBibwb5xT/pkY9BUL+E90zsuohPFYaTYZhTtwRa8StEXXWgX4hUDIFeZS1Wij3HyIXi4UJS3YwWQkMkIrWUeZD7GoU3Mef3qWXrE2uo5l30THPJZjKSGNs2WwCCPyMHArxcnjLZjwgzdFbHPQ== ollie@yubikey"
}

resource "aws_iam_role" "ecs_service_role" {
	name = "ecs_service_role"
	assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
	name = "ecs_service_role_policy"
	role = "${aws_iam_role.ecs_service_role.id}"
	policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

// Codebuild role
resource "aws_iam_role" "codebuild-role" {
	name = "codebuild-role"
	assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "codebuild-policy" {
	name = "codebuild-policy"
	path = "/"
	policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
		{
			"Action": [
				"ecr:BatchCheckLayerAvailability",
				"ecr:CompleteLayerUpload",
				"ecr:GetAuthorizationToken",
				"ecr:InitiateLayerUpload",
				"ecr:PutImage",
				"ecr:UploadLayerPart"
			],
			"Resource": "*",
			"Effect": "Allow"
		}
    ]
}
EOF
}
resource "aws_iam_policy_attachment" "codebuild-policy-attachment" {
	name = "codebuild-policy-attachment"
	policy_arn = "${aws_iam_policy.codebuild-policy.arn}"
	roles = ["${aws_iam_role.codebuild-role.id}"]
}
