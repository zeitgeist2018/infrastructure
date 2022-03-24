locals {
  vpc_cidr = "10.0.0.0/22"
  private_cidr = "10.0.1.0/24"
}

resource aws_vpc vpc {
  cidr_block = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.account.env}-vpc"
    ENV = var.account.env
  }
}

resource aws_internet_gateway gateway {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.account.env}-igw"
    ENV = var.account.env
  }
}

resource aws_subnet private_0 {
  vpc_id = aws_vpc.vpc.id
  cidr_block = local.private_cidr
  availability_zone = var.az
  tags = {
    Name = "${var.account.env}-private-subnet-0"
    ENV = var.account.env
  }
}

resource aws_route_table private_0 {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "${var.account.env}-route-table"
    ENV = var.account.env
  }
}

resource aws_route_table_association public-1 {
  subnet_id = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}
