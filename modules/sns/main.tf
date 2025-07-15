resource "aws_sns_topic" "topic" {
  name = "${var.project}-image-resize"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.subscription_email
}