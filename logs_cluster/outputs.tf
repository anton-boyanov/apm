output "cluster" {
  value = aws_cloudwatch_log_group.cluster.id
}
output "ecs-agent" {
  value = aws_cloudwatch_log_group.ecs-agent.id
}
output "dmesg" {
  value = aws_cloudwatch_log_group.dmesg.id
}
output "docker" {
  value = aws_cloudwatch_log_group.docker.id
}
output "ecs-init" {
  value = aws_cloudwatch_log_group.ecs-init.id
}
output "audit" {
  value = aws_cloudwatch_log_group.audit.id
}
output "messages" {
  value = aws_cloudwatch_log_group.messages.id
}
output "ssm-agent-errors" {
  value = aws_cloudwatch_log_group.ssm-agent-errors.id
}
output "ssm-agent" {
  value = aws_cloudwatch_log_group.ssm-agent.id
}
