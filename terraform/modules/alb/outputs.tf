output "alb_dns_name" { value = aws_lb.main.dns_name }
output "api_target_group_arn" { value = aws_lb_target_group.api.arn }
output "frontend_target_group_arn" { value = aws_lb_target_group.frontend.arn }
output "alb_security_group_id" { value = aws_security_group.alb.id }
