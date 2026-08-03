output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "ecr_api_url" {
  description = "ECR repository URL for stockroom-api"
  value       = module.ecr.api_repo_url
}

output "ecr_frontend_url" {
  description = "ECR repository URL for stockroom-frontend"
  value       = module.ecr.frontend_repo_url
}

output "rds_endpoint" {
  description = "RDS Postgres endpoint"
  value       = module.rds.db_endpoint
}
