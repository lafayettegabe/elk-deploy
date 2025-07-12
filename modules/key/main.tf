resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project}-key-${random_string.suffix.result}"
  public_key = file("${path.module}/elk.pub")
}
