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
  ami                         = "ami-0c02fb55956c7d316"
#  instance_type               = "t3a.nano"  // 2xCPU/512Mb/$3.50/month each
  instance_type               = "t3a.micro"  // 2xCPU/1Gb/$7/month each
  instance_name_suffix        = count.index
  subnet_id                   = var.subnet_id
  sg_id                       = aws_security_group.sg.id
  private_ip                  = "10.0.1.2${count.index}"
  elastic_ip                  = true
  associate_public_ip_address = true
  cloud_init_file = file("${path.module}/provisioning/cloud-config.yml")
  cloud_init_vars = {
    ENV = var.account.env
    REGION = var.account.region
    SLACK_WEBHOOK_URL = var.slack_webhook_url
    BUCKET = var.bucket
  }
}
