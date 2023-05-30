provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region  = var.region
}

resource "aws_iam_role" "greet_lamda_role" {
  name = "greet_lamda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy_greet_lambda" {
  name = "policy_greet_lambda"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_greet_lambda_attachment" {
  role       = aws_iam_role.greet_lamda_role.name
  policy_arn = aws_iam_policy.policy_greet_lambda.arn
}

data "archive_file" "greet_lambda_zip" {
    type = "zip"
    source_file = "${path.module}/${var.lambda_name}.py"
    output_path = "${path.module}/${var.lambda_file}"
}

resource "aws_lambda_function" "greet_lambda" {
  filename = var.lambda_file
  function_name = var.lambda_name
  role          = aws_iam_role.greet_lamda_role.arn
  handler       = "${var.lambda_name}.${var.lambda_handler_name}"
  runtime       = "python3.8"
  environment {
		variables = {
			greeting = "Greet Lambda Function"
		}
	}
}

locals {
  lambda_log_group = "/aws/lambda/${var.lambda_name}"
}