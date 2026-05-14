variable "aws_region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to identify project resources."
  type        = string
  default     = "secure-aws-baseline"
}

variable "environment" {
  description = "Environment name for tagging and naming."
  type        = string
  default     = "dev"

}