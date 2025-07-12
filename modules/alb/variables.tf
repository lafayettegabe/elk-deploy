variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "instance_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "domain_names" {
  type = map(string)
}

variable "certificate_arn" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
