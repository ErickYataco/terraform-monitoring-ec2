
resource "aws_iam_role" "ec2-prometheus-role" {
  name = "${var.PROJECT}-ec2-prometheus-role-${var.ENVIROMENT}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags =  {
    Name        = "${var.PROJECT}-iam-role-prometheus-${var.ENVIROMENT}"
    Owner       = "${var.OWNER}"
    Enviroment  = "${var.ENVIROMENT}"
    Tool        = "Terraform"
  }
  
}

resource "aws_iam_role_policy_attachment" "ec2-readonly-role-policy-attach" {
  role       = "${aws_iam_role.ec2-prometheus-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "${var.PROJECT}-instance-profile-${var.ENVIROMENT}"
  role = "${aws_iam_role.ec2-prometheus-role.name}"
}

resource "aws_security_group" "api_security_group" {
  name        = "${var.PROJECT}-ec2-sg-${var.ENVIROMENT}"
  description = "security group for prometheus instance"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name        = "${var.PROJECT}-ec2-sg-${var.ENVIROMENT}"
    Owner       = "${var.OWNER}"
    Enviroment  = "${var.ENVIROMENT}"
    Tool        = "Terraform"
  }
}
# TODO BIND PROMETHEUS AND ADD DASHBOARDS
data "template_file" "init" {
  template = "${file("${path.module}/scripts/install_monitor.sh")}"
  vars = {
    region    = "${var.REGION}"
    project   = "${var.PROJECT}"
    role      = "${aws_iam_role.ec2-prometheus-role.arn}"
  }
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "${var.PROJECT}-key-prometheus-${var.ENVIROMENT}"
  public_key = "${file("${path.root}/${var.PATH_TO_PUBLIC_KEY}")}"
}

# TODO SG to open ports
resource "aws_instance" "monitor" {
  ami                   = "${var.AMIS[var.REGION]}"
  instance_type         = "${var.INSTANCE_TYPE}"
  key_name              = "${aws_key_pair.mykeypair.key_name}"  
  iam_instance_profile  = "${aws_iam_instance_profile.monitoring_profile.id}"
  user_data             = "${data.template_file.init.rendered}"
  
  # TODO aws_volume_attachment
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }

  tags =  {
    Name        = "${var.PROJECT}-ec2-prometheus-${var.ENVIROMENT}"
    Owner       = "${var.OWNER}"
    Enviroment  = "${var.ENVIROMENT}"
    Tool        = "Terraform"
  }
}


