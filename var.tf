variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "rocidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "name" {
  type    = string
  default = "cgv-prod"
}

variable "tag" {
  type        = string
  default     = "cgv-chill-guy"
}

variable "access_key" {
  type        = string
}

variable "secret_key" {
  type        = string
}

variable "db_username" {
  type        = string
}

variable "db_password" {
  type        = string
}

variable "db_name" {
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
