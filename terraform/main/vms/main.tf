data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
}
# TODO: Open only port 80 for entrypoint node nginx. The rest should be closed
resource aws_security_group nomad-sg{
  vpc_id = var.vpc_id
  name = "${var.cluster}-nomad-sg"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  tags = {
    "Name" = "${var.cluster}-nomad-sg"
  }
}

// TODO: Create security group with proper route tables
module nomad-node {
  count = 2
  source = "../../modules/ec2-instance"

  vpc_id = var.vpc_id
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3a.small"
  instance_name_suffix = count.index
  subnet_id = var.subnet_id
  sg_id = aws_security_group.nomad-sg.id
  private_ip = "10.0.1.2${count.index}"
  cluster = local.tags.Cluster
  application = "nomad"
  elastic_ip = true
  associate_public_ip_address = true
  env = var.env
  region = var.region
}
