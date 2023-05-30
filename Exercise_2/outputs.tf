# TODO: Define the output variable for the lambda function.
output "arn" {
  description = "Amazon resouce name for greet lambda udacity"
  value       = aws_lambda_function.greet_lambda.arn
}