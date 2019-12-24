output "lb_sg" {
  value = aws_security_group.lb_sg.id
}
output "instance_sg" {
  value = aws_security_group.instance_sg.id
}