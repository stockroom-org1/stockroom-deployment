variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr_block" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "tags" { type = map(string) }
