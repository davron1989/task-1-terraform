provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "task-1" {
  ami           = "ami-0d6621c01e8c2de2c"
  instance_type = "t2.large"
  availability_zone = "us-west-2a"
  key_name      = "${aws_key_pair.davron-task-1.key_name}"
  security_groups = ["${aws_security_group.sec-group-task-1.name}"]
  user_data     = "${file("install_httpd.sh")}"
  tags = {
    Name = "task-1"
  }
}

resource "aws_ebs_volume" "data-vol" {
 availability_zone = "us-west-2a"
 size = 100
 tags = {
        Name = "data-volume"
 }

}

resource "aws_volume_attachment" "good-morning-vol" {
 device_name = "/dev/sdc"
 volume_id = "${aws_ebs_volume.data-vol.id}"
 instance_id = "${aws_instance.task-1.id}"
}


resource "aws_key_pair" "davron-task-1" {
  key_name   = "davron-task-1"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}




resource "aws_security_group" "sec-group-task-1" {
  name        = "sec-group-task-1"
  description = "Allow HTTP and HTTPS inbound traffic"
 

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "tcp from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-task-1"
  }
}

resource "aws_route53_zone" "zone-task1" {
    name = "davrononline.com"
  
}

resource "aws_route53_record" "record-task1" {
    zone_id = "${aws_route53_zone.zone-task1.zone_id}"
    name    = "server.davron"
    type    = "A"
    ttl     = "300"
    records = ["34.219.182.6"]
  
}

