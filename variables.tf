variable "region" {
  description = "La región donde se creará la infraestructura."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "El bloque CIDR para la VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "El bloque CIDR para la subnet pública."
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "El bloque CIDR para la subnet privada."
  default     = "10.0.2.0/24"
}
