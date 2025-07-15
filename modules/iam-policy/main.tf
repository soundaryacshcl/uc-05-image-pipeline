locals {
  name_prefix = "${var.project}-${terraform.workspace}"
}

########################
#  Trust Policy (STS)  #
########################

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

############################
#  IAM Role for the Lambda #
############################

resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json

  tags = {
    Project     = var.project
    Environment = terraform.workspace
  }
}

#########################################
#  Least‑Privilege Inline Policy JSON   #
#########################################

data "aws_iam_policy_document" "lambda_policy" {

  # S3 object‑level access (read from uploads, write to resized)
  statement {
    sid       = "S3ObjectAccess"
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${var.source_bucket_arn}/*",
      "${var.dest_bucket_arn}/*"
    ]
  }

  # Publish success/failure notifications
  statement {
    sid       = "SNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [var.sns_topic_arn]
  }

  # CloudWatch Logs for Lambda executions
  statement {
    sid       = "CloudWatchLogs"
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

#########################################
#  Attach the inline policy to the role #
#########################################

resource "aws_iam_role_policy" "lambda" {
  name   = "${local.name_prefix}-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}
