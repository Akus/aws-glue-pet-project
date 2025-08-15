# Lambda IAM role
resource "aws_iam_role" "trigger_lambda_role" {
  name = "trigger-stepfn-from-s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "trigger_lambda_policy" {
  name = "trigger-stepfn-from-s3-policy"
  role = aws_iam_role.trigger_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = aws_sfn_state_machine.move_latest.arn
      }
    ]
  })
}

# Lambda function to start Step Function
resource "aws_lambda_function" "trigger_stepfn" {
  filename         = "trigger_stepfn.zip"
  function_name    = "trigger-stepfn-on-s3"
  role             = aws_iam_role.trigger_lambda_role.arn
  handler          = "trigger_stepfn.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("trigger_stepfn.zip")
  timeout          = 30
  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.move_latest.arn
    }
  }
}

# S3 bucket notification triggers Lambda on create in output/
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_stepfn.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "output/"
  }
}

# Give S3 permission to invoke Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_stepfn.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::glue-modular-demo-pure-kit"
}