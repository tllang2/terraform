output "load_balancer_endpoint" {
  value = aws_lb.nginx.dns_name
}