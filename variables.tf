variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"  # Plage CIDR du VPC
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"  # Plage CIDR du subnet public
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"  # Plage CIDR du subnet privé
}