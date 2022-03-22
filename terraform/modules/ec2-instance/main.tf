locals {
  output_folder = "output"
}

resource local_file private_key_file {
  content = tls_private_key.private_key.private_key_pem
  filename = "${local.output_folder}/${var.cluster}-${var.application}-${var.instance_name_suffix}-private-key.pem"
}

resource local_file instance_public_dns_file {
  content = aws_instance.instance.public_dns
  filename = "${local.output_folder}/${var.cluster}-${var.application}-${var.instance_name_suffix}-public-dns.txt"
}

resource local_file instance_public_ip_file {
  content = aws_instance.instance.public_ip
  filename = "${local.output_folder}/${var.cluster}-${var.application}-${var.instance_name_suffix}-public-ip.txt"
}

resource tls_private_key private_key {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource aws_key_pair instance_key_pair {
  key_name = "${var.cluster}-${var.application}-${var.instance_name_suffix}-key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource aws_eip elastic_ip {
  count = var.elastic_ip == true ? 1 : 0
  vpc = true
  instance = aws_instance.instance.id
  associate_with_private_ip = var.private_ip
}

resource aws_instance instance {
  ami = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [var.sg_id]
  subnet_id = var.subnet_id
  private_ip = var.private_ip
  associate_public_ip_address = var.associate_public_ip_address
  key_name = aws_key_pair.instance_key_pair.key_name

  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = var.disk
    volume_type = "gp3"
    iops = 3000
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${var.cluster}-${var.application}-${var.instance_name_suffix}"
    }
  )

  volume_tags = merge(
    local.tags,
    {
      "Name" = "${var.cluster}-${var.application}-${var.instance_name_suffix}"
    }
  )
}
