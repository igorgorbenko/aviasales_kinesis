#--------------------------------------------------------------
# New SNS topic
#--------------------------------------------------------------

locals {
  display_name = var.topic_name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "delivery_status_role_inline_policy" {
  statement {
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
  }
}


data "aws_iam_policy_document" "publish" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.topic.arn]
  }
}

resource "aws_iam_policy" "publish" {
  name        = "sms-publish"
  path        = "/"
  description = "Allow publishing to Group SMS SNS Topic"
  policy      = data.aws_iam_policy_document.publish.json
}

resource "aws_iam_role" "delivery_status_role" {
  description        = "Allow AWS to publish SMS delivery status logs"
  name               = "SNSSuccessFeedback"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "delivery_status_role_inline_policy" {
  name   = aws_iam_role.delivery_status_role.name
  role   = aws_iam_role.delivery_status_role.id
  policy = data.aws_iam_policy_document.delivery_status_role_inline_policy.json
}

resource "aws_sns_topic" "topic" {
  display_name = var.topic_name
  name         = var.topic_name
}

resource "aws_sns_topic_subscription" "subscription" {
  count     = length(var.subscriptions)
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "sms"
  endpoint  = var.subscriptions
}
