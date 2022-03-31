resource aws_dynamodb_table cluster {
  name = "${var.account.env}-cluster_control"
  billing_mode = "PROVISIONED"
  table_class = "STANDARD"
  read_capacity = 1
  write_capacity = 1
  hash_key = "IP"
  tags = var.tags

  attribute {
    name = "IP"
    type = "S"
  }
}
