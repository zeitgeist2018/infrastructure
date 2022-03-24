output vpc_id {
  value = aws_vpc.vpc.id
}

output subnet_ids {
  value = {
    private_0 = aws_subnet.private_0.id
  }
}