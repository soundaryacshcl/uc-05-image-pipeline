###############################################################################
# ── 0. Locals ────────────────────────────────────────────────────────────────
locals {
  layer_zip_local  = "${path.module}/layers/pillow-layer.zip"   # pre‑built layer
  code_dir_local   = "${path.module}/src"                       # .py lives here
  code_zip_local   = "${path.module}/src/code.zip"              # auto‑built (see archive_file)
}

###############################################################################
# ── 1. Upload pre‑built Pillow layer ZIP to S3 ───────────────────────────────
resource "aws_s3_object" "pillow_layer_zip" {
  bucket = var.layer_s3_bucket                         # source bucket
  key    = "layers/pillow-layer.zip"
  source = local.layer_zip_local
  etag   = filemd5(local.layer_zip_local)
}

resource "aws_lambda_layer_version" "pillow" {
  layer_name          = "${var.project}-pillow"
  s3_bucket           = var.layer_s3_bucket
  s3_key              = aws_s3_object.pillow_layer_zip.key
  compatible_runtimes = ["python3.9"]
}

###############################################################################
# ── 2. Build & upload Lambda code ZIP automatically ─────────────────────────
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = local.code_dir_local               # expects lambda_function.py here
  output_path = local.code_zip_local
}

resource "aws_s3_object" "lambda_code_zip" {
  bucket = var.lambda_s3_bucket
  key    = "lambda/code.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

###############################################################################
# ── 3. Lambda function ──────────────────────────────────────────────────────
resource "aws_lambda_function" "image_resize" {
  function_name = "${var.project}-image-resize"
  role          = var.role_arn

  runtime  = "python3.9"
  handler  = "lambda_function.lambda_handler"

  s3_bucket = var.lambda_s3_bucket
  s3_key    = aws_s3_object.lambda_code_zip.key

  memory_size = var.memory_size
  timeout     = var.timeout
  layers      = [aws_lambda_layer_version.pillow.arn]

  environment {
    variables = {
      DEST_BUCKET   = var.dest_bucket_name
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  depends_on = [aws_lambda_layer_version.pillow]
}

###############################################################################
# ── 4. Allow source bucket to invoke Lambda ─────────────────────────────────
data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_resize.arn
  principal     = "s3.amazonaws.com"

  source_arn     = var.source_bucket_arn                          # arn:aws:s3:::bucket
  source_account = data.aws_caller_identity.current.account_id
}

###############################################################################
# ── 5. S3 → Lambda notification ────────────────────────────────────────────
resource "aws_s3_bucket_notification" "trigger" {
  bucket = var.source_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_resize.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}


