data aws_ami amazon_linux {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
}
# TODO: Open only port 80/443 for entrypoint node nginx. The rest should be closed
resource aws_security_group sg {
  vpc_id = var.vpc_id
  name   = "${var.account.env}-sg"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = merge({
    Name = "${var.account.env}-vpc"
  }, var.tags)
}

// TODO: Create security group with proper route tables
module nodes {
  count  = 1
  source = "../../modules/ec2-instance"

  account                     = var.account
  tags                        = var.tags
  vpc_id                      = var.vpc_id
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t4g.nano"  // 2xCPU/512Mb/$6/month each
#  instance_type               = "t4g.micro"  // 2xCPU/1Gb/$9/month each
  instance_name_suffix        = count.index
  subnet_id                   = var.subnet_id
  sg_id                       = aws_security_group.sg.id
  private_ip                  = "10.0.1.2${count.index}"
  elastic_ip                  = true
  associate_public_ip_address = true
  cloud_init_file = file("${path.root}/../provisioning/cloud-config.yml")
}
