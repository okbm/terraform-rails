terraform {
  required_version = "= 0.11.8"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# sesはtokyoにはないので、別リージョンを用意
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${file(var.ssh_public_key_path)}"
}
