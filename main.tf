module "s3" {
  source             = "./modules/s3"
  project            = var.project
  source_bucket_name = var.source_bucket_name
  dest_bucket_name   = var.dest_bucket_name
}

module "iam" {
  source  = "./modules/iam-policy"
  project = var.project
}

module "sns" {
  source             = "./modules/sns"
  project            = var.project
  subscription_email = var.subscription_email
}

module "lambda" {
  source  = "./modules/lambda"
  project = var.project

  role_arn          = module.iam.role_arn
  source_bucket_id  = module.s3.source_bucket_id  # for notification
  source_bucket_arn = module.s3.source_bucket_arn # for permission
  dest_bucket_name  = module.s3.dest_bucket_name
  sns_topic_arn     = module.sns.topic_arn

  layer_s3_bucket  = module.s3.source_bucket_name
  layer_s3_key     = "layers/pillow-layer.zip"
  lambda_s3_bucket = module.s3.source_bucket_name
  lambda_s3_key    = "lambda/code.zip"
}
