resource "aws_alb" "alb" {
  name            = "fashion-flux-alb"
  subnets         = aws_subnet.public_subnet.*.id
  security_groups = [aws_security_group.alb-sg.id]
}

resource "aws_alb_target_group" "fashion-flux-tg" {
  name        = "fashion-flux-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/"
    interval            = 30
  }
}

#redirecting all incomming traffic from ALB to the target group
resource "aws_alb_listener" "fashion-flux-listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.fashion-flux-tg.arn
  }
}
