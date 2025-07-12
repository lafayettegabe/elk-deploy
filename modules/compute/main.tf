resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = base64encode(
    templatefile("${path.module}/../../scripts/init.sh", {
      monitoring_url      = var.monitoring_url,
      apm_url             = var.apm_url,
      discord_webhook_url = var.discord_webhook_url
    })
  )

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(var.common_tags, { Name = "${var.project}-ec2" })
}

resource "aws_ebs_volume" "elk_data" {
  availability_zone = aws_instance.main.availability_zone
  size              = 30
  type              = "gp3"
  tags              = var.common_tags
}

resource "aws_volume_attachment" "elk_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.elk_data.id
  instance_id = aws_instance.main.id
}
