
resource aws_iam_role instance_role {
  name               = "${var.account.env}-node"
  path               = "/common/"
  assume_role_policy = data.aws_iam_policy_document.instance.json
}

data aws_iam_policy_document instance {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource aws_iam_role_policy instance {
  name   = "${var.account.env}-node"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.instance_permissions.json
}

resource aws_iam_instance_profile instance {
  name = "${var.account.env}-node"
  role = aws_iam_role.instance_role.id
}

data aws_iam_policy_document instance_permissions {
  statement {
    effect = "Allow"

    actions = [
      #      "ec2:AssignPrivateIpAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "sts:AssumeRole",
      "sts:GetFederationToken",
      "sts:GetSessionToken",
    ]

    resources = [
      "*",
    ]
  }
}
