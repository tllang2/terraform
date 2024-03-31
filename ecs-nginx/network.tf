resource "aws_security_group" "nginx" {
  name   = "nginx-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create a public facing load balancer
resource "aws_lb" "nginx" {
  name            = "nginx-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.nginx.id]
}

resource "aws_lb_target_group" "nginx" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nginx.id
    type             = "forward"
  }
}