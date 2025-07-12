locals {
  project       = "elk-server"
  region        = "us-east-1"
  instance_type = "t4g.large"

  monitoring_url = "${var.monitoring_subdomain}.${var.domain_name}"
  apm_url        = "${var.apm_subdomain}.${var.domain_name}"

  common_tags = {
    Project   = local.project
    Terraform = "true"
  }
}
