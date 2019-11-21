
data "template_file" "init" {
  template = "${file("${path.module}/scripts/install_monitored.sh")}"
  
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "${var.PROJECT}-key-node-${var.ENVIROMENT}"
  public_key = "${file("${path.root}/${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "monitored" {
  count                 = "${var.INSTANCES_NUMBER}"
  ami                   = "${var.AMIS[var.REGION]}"
  instance_type         = "${var.INSTANCE_TYPE}"
  key_name              = "${aws_key_pair.mykeypair.key_name}"  
  user_data             = "${data.template_file.init.rendered}"
  
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }

  tags = {
    Name        = "${var.PROJECT}-ec2-node-${var.ENVIROMENT}-${count.index}"
    Owner       = "${var.OWNER}"
    Enviroment  = "${var.ENVIROMENT}"
    Tool        = "Terraform"
  }
}


