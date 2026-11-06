output "vpc_id" {
  description = "Identifiant du VPC DEV"
  value       = module.network.vpc_id
}

output "alb_dns_name" {
  description = "Adresse publique du Load Balancer"
  value       = module.web_stack.alb_dns_name
}

output "public_subnet_ids" {
  description = "Subnets publics du VPC"
  value       = module.network.public_subnets
}
