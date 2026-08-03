variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "api_image_uri" { type = string }
variable "frontend_image_uri" { type = string }
variable "api_target_group_arn" { type = string }
variable "frontend_target_group_arn" { type = string }
variable "database_url" {
  type      = string
  sensitive = true
}
variable "api_key" {
  type      = string
  sensitive = true
}
variable "tags" { type = map(string) }
