resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}-vpc"
  }

  lifecycle {
    prevent_destroy       = false
  }
}

resource "aws_subnet" "public_web" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-public-web"
  }
}

resource "aws_subnet" "private_db1" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags {
    Name = "${var.name}-private-db1"
  }
}

resource "aws_subnet" "private_db2" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags {
    Name = "${var.name}-private-db2"
  }
}

resource "aws_subnet" "public_https" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-public-https"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-gw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "${var.name}-rtb"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_web.id}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_https.id}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}

resource "aws_security_group" "app" {
  name        = "${var.name}_web"
  description = "It is a security group on http of vpc"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-web"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "web" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group_rule" "all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group" "db" {
  name        = "db_server"
  description = "It is a security group on db of vpc."
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-db"
  }
}

resource "aws_security_group_rule" "db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.app.id}"
  security_group_id        = "${aws_security_group.db.id}"
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.name}_dbsubnet"
  description = "It is a DB subnet group on vpc."
  subnet_ids  = ["${aws_subnet.private_db1.id}", "${aws_subnet.private_db2.id}"]

  tags {
    Name = "${var.name}-dbsubnet"
  }

  lifecycle {
    ignore_changes = ["name"]
  }
}
