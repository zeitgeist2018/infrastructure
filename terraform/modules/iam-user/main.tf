module labels {
  source = "../labels"

  name        = var.name
  environment = var.environment
  attributes  = var.attributes
  label_order = var.label_order
}

# Module      : IAM user
# Description : Terraform module to create IAm user resource on AWS.
resource aws_iam_user default {
  count = var.enabled ? 1 : 0

  name                 = module.labels.id
  force_destroy        = var.force_destroy
  path                 = var.path
  permissions_boundary = var.permissions_boundary
  tags                 = module.labels.tags
}

resource aws_iam_access_key default {
  count = var.enabled ? 1 : 0

  user    = aws_iam_user.default.*.name[0]
  pgp_key = var.pgp_key
  status  = var.status
}

resource aws_iam_user_policy default {
  count = var.enabled && var.policy_enabled && var.policy_arn == "" ? 1 : 0

  name   = format("%s-policy", module.labels.id)
  user   = aws_iam_user.default.*.name[0]
  policy = var.policy
}

resource aws_iam_user_policy_attachment default {
  count = var.enabled && var.policy_enabled && var.policy_arn != "" ? 1 : 0

  user       = aws_iam_user.default.*.name[0]
  policy_arn = var.policy_arn
}
