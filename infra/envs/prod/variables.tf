variable "environment" {
  description = "Environnement AWS"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Utiliser dev ou prod."
  }
}

variable "vpc_cidr" {
  description = "Adresse du reseau VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_password" {
  description = "Secret applicatif NovaSphere"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "instance_type" {
  description = "Type des instances EC2"
  type        = string
}

variable "desired_capacity" {
  description = "Nombre d'instances souhaite"
  type        = number

  validation {
    condition     = var.desired_capacity >= 2 && var.desired_capacity <= 4
    error_message = "La capacite doit etre entre 2 et 4."
  }
}
