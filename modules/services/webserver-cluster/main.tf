// ASG config
resource "aws_launch_configuration" "example" {
  image_id        = "ami-0823c236601fef765"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data       = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]

  max_size = var.max_size
  min_size = var.min_size

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg-example"
    propagate_at_launch = true
  }

}
// ALB config
resource "aws_lb" "example" {
  load_balancer_type = "application"
  name               = "${var.cluster_name}-alb"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    target_group_arn = aws_lb_target_group.asg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "${var.cluster_name}-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    healthy_threshold   = 2
    interval            = 15
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 3
    unhealthy_threshold = 2

  }
}
// Security group for ALB
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  cidr_blocks       = local.all_ips
  from_port         = local.http_port
  protocol          = local.tcp_protocol
  security_group_id = aws_security_group.alb.id
  to_port           = local.http_port
  type              = "ingress"
}
resource "aws_security_group_rule" "allow_alb_http_outbound" {
  cidr_blocks       = local.all_ips
  from_port         = local.any_port
  protocol          = local.any_protocol
  security_group_id = aws_security_group.alb.id
  to_port           = local.any_port
  type              = "egress"
}

//Security group for EC 2 instance
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}
resource "aws_security_group_rule" "allow_ec2_8080_inbound" {
  cidr_blocks       = local.all_ips
  from_port         = var.server_port
  protocol          = local.tcp_protocol
  security_group_id = aws_security_group.instance.id
  to_port           = var.server_port
  type              = "ingress"
}
