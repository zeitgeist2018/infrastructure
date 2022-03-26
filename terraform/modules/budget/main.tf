#resource aws_sns_topic account_billing_alarm_topic {
#  name = "${var.account.env}-account-billing-alarm-topic"
#}
#
#resource aws_sns_topic_policy account_billing_alarm_policy {
#  arn    = aws_sns_topic.account_billing_alarm_topic.arn
#  policy = data.aws_iam_policy_document.sns_topic_policy.json
#}
#
#data aws_iam_policy_document sns_topic_policy {
#
#  statement {
#    sid    = "AWSBudgetsSNSPublishingPermissions"
#    effect = "Allow"
#
#    actions = [
#      "SNS:Receive",
#      "SNS:Publish"
#    ]
#
#    principals {
#      type        = "Service"
#      identifiers = ["budgets.amazonaws.com"]
#    }
#
#    resources = [
#      aws_sns_topic.account_billing_alarm_topic.arn
#    ]
#  }
#}

resource aws_budgets_budget budget_account {
  name              = "${var.account.env} monthly budget"
  budget_type       = "COST"
  limit_amount      = var.account_budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2022-03-01_00:00"

#  notification {
#    comparison_operator       = "GREATER_THAN"
#    threshold                 = var.threshold_percentage
#    threshold_type            = "PERCENTAGE"
#    notification_type         = "FORECASTED"
#    subscriber_sns_topic_arns = [
#      aws_sns_topic.account_billing_alarm_topic.arn
#    ]
#  }
#
#  depends_on = [
#    aws_sns_topic.account_billing_alarm_topic
#  ]
}

resource aws_budgets_budget budget_resources {
  for_each = var.services

  name              = "${var.account.env} ${each.key} monthly budget"
  budget_type       = "COST"
  limit_amount      = each.value.budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2022-03-01_00:00"

  cost_filters = {
    name = "Service"
    values = lookup(local.aws_services, each.key)
  }

#  notification {
#    comparison_operator       = "GREATER_THAN"
#    threshold                 = var.threshold_percentage
#    threshold_type            = "PERCENTAGE"
#    notification_type         = "FORECASTED"
#    subscriber_sns_topic_arns = [
#      aws_sns_topic.account_billing_alarm_topic.arn
#    ]
#  }
#
#  depends_on = [
#    aws_sns_topic.account_billing_alarm_topic
#  ]
}
