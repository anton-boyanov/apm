
data "aws_vpc" "vpc" {
  filter {
    name = "tag:Environment"
    values = [
      var.environment
    ]
  }
}


resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = data.aws_vpc.vpc.id
  name   = "${var.application_name}-${var.environment}-alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9092
    to_port     = 9092
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = data.aws_vpc.vpc.id
  name        = "application-instances-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    description = "Access from ALB"

    security_groups = [
      aws_security_group.lb_sg.id,
    ]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "where is network lb"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}