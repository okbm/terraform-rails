# ec2, rds
resource "aws_s3_bucket" "b" {
  bucket = "document-private-bucket"
  acl    = "private"
}

resource "aws_db_instance" "db" {
  identifier              = "dbinstance"
  allocated_storage       = 5
  engine                  = "mysql"
  engine_version          = "5.7.17"
  instance_class          = "db.t2.micro"
  storage_type            = "gp2"
  username                = "${var.aws_db_username}"
  password                = "${var.aws_db_password}"
  backup_retention_period = 1
  vpc_security_group_ids  = ["${aws_security_group.db.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.main.name}"

  lifecycle {
    prevent_destroy       = false
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-9c9443e3"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.auth.id}"
  vpc_security_group_ids      = ["${aws_security_group.app.id}"]
  subnet_id                   = "${aws_subnet.public_web.id}"
  associate_public_ip_address = "true"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device = {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }

  tags {
    Name = "web_instance"
  }
}

resource "aws_eip" "web" {
  instance = "${aws_instance.web.id}"
  vpc      = true
}

resource "null_resource" "provision_master" {
  triggers {
    endpoint = "${aws_instance.web.id}"
  }

  connection {
    type        = "ssh"
    timeout     = "30s"
    agent       = false
    user        = "ec2-user"
    host        = "${aws_eip.web.public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
  }

  provisioner "file" {
    source      = "tmp/script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
    ]
  }

  provisioner "file" {
    source      = "conf/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/nginx.conf /etc/nginx/",
    ]
  }
}

output "elastic_ip_of_web" {
  value = "${aws_eip.web.public_ip}"
}
