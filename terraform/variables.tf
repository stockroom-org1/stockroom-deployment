variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
  default     = "stockroom"
}

variable "environment" {
  description = "Deployment environment (prod, staging)"
  type        = string
  default     = "prod"
}

variable "api_image_uri" {
  description = "Full ECR URI for the stockroom-api image (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/stockroom-api:latest)"
  type        = string
}

variable "frontend_image_uri" {
  description = "Full ECR URI for the stockroom-frontend image"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS Postgres database"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API key for the stockroom-api service (X-API-Key header)"
  type        = string
  sensitive   = true
}
