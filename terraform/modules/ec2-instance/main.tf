locals {
  instance_name = "${var.account.env}-${var.instance_name_suffix}"
  output        = {
    private_key = "./output/${local.instance_name}-private-key.pem"
    config      = "./output/${local.instance_name}-config.json"
  }
}

resource local_file private_key {
  content         = tls_private_key.private_key.private_key_pem
  filename        = local.output.private_key
  file_permission = "600"
}

resource local_file config {
  content    = <<EOF
{
  "public_ip": "${aws_instance.instance.public_ip}",
  "private_ip": "${aws_instance.instance.private_ip}",
  "public_dns": "${aws_instance.instance.public_dns}"
}
EOF
  filename   = local.output.config
  depends_on = [aws_instance.instance]
}

resource tls_private_key private_key {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource aws_key_pair instance_key_pair {
  key_name   = "${local.instance_name}-key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource aws_eip elastic_ip {
  count                     = var.elastic_ip == true ? 1 : 0
  vpc                       = true
  instance                  = aws_instance.instance.id
  associate_with_private_ip = var.private_ip
}

data template_file cloud_init {
  template = var.cloud_init_file
  vars     = merge({
    REGION = var.account.region
  }, var.cloud_init_vars)
}

resource aws_instance instance {
  ami                         = var.ami
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = aws_key_pair.instance_key_pair.key_name

  user_data = base64encode(data.template_file.cloud_init.rendered)

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = var.disk
    volume_type           = "gp3"
    iops                  = 3000
  }

  tags = merge({
    Name = local.instance_name
  }, var.tags)

  volume_tags = merge({
    Name = local.instance_name
  }, var.tags)
}
