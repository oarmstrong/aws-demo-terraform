// VPC
resource "aws_vpc" "production" {
	cidr_block = "10.99.0.0/16"
}

// Subnets
resource "aws_subnet" "production-2a" {
	cidr_block = "10.99.1.0/24"
	availability_zone = "eu-west-2a"
	vpc_id = "${aws_vpc.production.id}"
}
resource "aws_subnet" "production-2b" {
	cidr_block = "10.99.10.0/24"
	availability_zone = "eu-west-2b"
	vpc_id = "${aws_vpc.production.id}"
}

// Routing
resource "aws_internet_gateway" "igw" {
	vpc_id = "${aws_vpc.production.id}"
}
resource "aws_route_table" "rt" {
	vpc_id = "${aws_vpc.production.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.igw.id}"
	}
}
resource "aws_route_table_association" "rta-2a" {
	subnet_id = "${aws_subnet.production-2a.id}"
	route_table_id = "${aws_route_table.rt.id}"
}
resource "aws_route_table_association" "rta-2b" {
	subnet_id = "${aws_subnet.production-2b.id}"
	route_table_id = "${aws_route_table.rt.id}"
}

// Security groups
resource "aws_security_group" "allow_all" {
	name = "allow_all"
	description = "Allow all traffic ingress and egress"
	vpc_id = "${aws_vpc.production.id}"

	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

// Domain
resource "aws_route53_zone" "primary" {
	name = "aws.oarmstrong.us"
}
