output "lambda_function_arn" {
  value = module.lambda.function_arn
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}