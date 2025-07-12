module "security" {
  source      = "./modules/security"
  project     = local.project
  vpc_id      = data.aws_vpc.selected.id
  common_tags = local.common_tags
}

module "key" {
  source  = "./modules/key"
  project = local.project
}

module "compute" {
  source                 = "./modules/compute"
  project                = local.project
  ami_id                 = data.aws_ami.ubuntu_arm.id
  instance_type          = local.instance_type
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [module.security.instance_sg_id]
  key_name               = module.key.key_name
  monitoring_url         = local.monitoring_url
  apm_url                = local.apm_url
  discord_webhook_url    = var.discord_webhook_url
  common_tags            = local.common_tags
}

module "alb" {
  source         = "./modules/alb"
  project        = local.project
  vpc_id         = data.aws_vpc.selected.id
  public_subnets = data.aws_subnets.public.ids
  instance_id    = module.compute.instance_id
  alb_sg_id      = module.security.alb_sg_id
  domain_names = {
    monitoring = local.monitoring_url
    apm        = local.apm_url
  }
  certificate_arn = var.acm_certificate_arn
  common_tags     = local.common_tags
}

module "dns" {
  source       = "./modules/dns"
  zone_id      = data.aws_route53_zone.selected.zone_id
  monitoring   = local.monitoring_url
  apm          = local.apm_url
  alb_dns_name = module.alb.lb_dns_name
  alb_zone_id  = module.alb.lb_zone_id
}
