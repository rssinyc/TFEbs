provider "aws" {
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

resource "aws_instance" "ec2_instance" {
  ami           = var.aminame
  instance_type = var.instance_type
  availability_zone = "us-east-1a"  # Replace with your desired availability zone

  tags = {
    "Name"    = "testintance"
    "testtag" = "test"
  }

  user_data = <<-EOF
#!/usr/bin/env bash
set -x
dnf install -y kpatch-dnf
dnf kernel-livepatch -y auto
dnf install -y kpatch-runtime
dnf update kpatch-runtime
systemctl enable kpatch.service
systemctl start kpatch.service
systemctl start nginx
echo "Hello World" > /tmp/hello.txt
EOF
}

resource "aws_ebs_volume" "ebs_volume" {
  count             = 3
  availability_zone = "us-east-1a"  # Replace with your desired availability zone
  size              = 1800
  type              = "gp3"
}

locals {
  device_names = ["xvdb", "xvdc", "xvdd"]
}

resource "aws_volume_attachment" "ebs_attachment" {
  count       = 3
  volume_id   = aws_ebs_volume.ebs_volume[count.index].id
  instance_id = aws_instance.ec2_instance.id
  device_name = "/dev/${local.device_names[count.index]}"
}
