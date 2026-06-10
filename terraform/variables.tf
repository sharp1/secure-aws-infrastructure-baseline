variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string

}

variable "public_subnet_a_cidr" {
  description = "CIDR block for Public Subnet A"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for Public Subnet B"
  type        = string
}

variable "private_app_subnet_a_cidr" {
  description = "CIDR block for Private App Subnet A"
  type        = string
}

variable "private_app_subnet_b_cidr" {
  description = "CIDR block for Private App Subnet B"
  type        = string
}

variable "private_data_subnet_a_cidr" {
  description = "CIDR block for Private Data Subnet A"
  type        = string

}

variable "private_data_subnet_b_cidr" {
  description = "CIDR block for Private Data Subnet B"
  type        = string

}

variable "az_a" {
  description = "Availability Zone A"
  type        = string
}

variable "az_b" {
  description = "Availability Zone B"
  type        = string
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
}