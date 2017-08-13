// VPC
resource "aws_vpc" "production" {
	cidr_block = "10.99.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

// Subnets
resource "aws_subnet" "production-1a" {
	cidr_block = "10.99.1.0/24"
	availability_zone = "eu-west-1a"
	vpc_id = "${aws_vpc.production.id}"
}
resource "aws_subnet" "production-1b" {
	cidr_block = "10.99.10.0/24"
	availability_zone = "eu-west-1b"
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
resource "aws_route_table_association" "rta-1a" {
	subnet_id = "${aws_subnet.production-1a.id}"
	route_table_id = "${aws_route_table.rt.id}"
}
resource "aws_route_table_association" "rta-1b" {
	subnet_id = "${aws_subnet.production-1b.id}"
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
