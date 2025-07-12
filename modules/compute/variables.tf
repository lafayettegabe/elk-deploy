variable "project" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "monitoring_url" {
  type = string
}

variable "apm_url" {
  type = string
}

variable "discord_webhook_url" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
