# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "glue-move-latest-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Lambda permissions for S3
resource "aws_iam_role_policy" "lambda_policy" {
  name = "glue-move-latest-lambda-policy"
  role = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::glue-modular-demo-pure-kit",
      "arn:aws:s3:::glue-modular-demo-pure-kit/output/*",
      "arn:aws:s3:::glue-modular-demo-pure-kit/output-latest/*"
    ]
  }
}

# Lambda: Find latest file
resource "aws_lambda_function" "find_latest" {
  filename         = "find_latest.zip" # Package this Python (or Node.js) code
  function_name    = "find-latest-file"
  role             = aws_iam_role.lambda_role.arn
  handler          = "find_latest.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("find_latest.zip")
  timeout          = 30
  environment {
    variables = {
      BUCKET = var.bucket_name
      PREFIX = var.output_prefix
    }
  }
}

# Lambda: Copy file
resource "aws_lambda_function" "copy_file" {
  filename         = "copy_file.zip"
  function_name    = "copy-latest-file"
  role             = aws_iam_role.lambda_role.arn
  handler          = "copy_file.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("copy_file.zip")
  timeout          = 30
  environment {
    variables = {
      BUCKET      = var.bucket_name
      DEST_PREFIX = "${var.output_prefix}latest/"
    }
  }
}

# Step Function State Machine definition
data "aws_iam_policy_document" "stepfn_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "stepfn_role" {
  name = "glue-move-latest-stepfn-role"
  assume_role_policy = data.aws_iam_policy_document.stepfn_assume.json
}

resource "aws_iam_role_policy" "stepfn_invoke_lambda" {
  name = "stepfn-invoke-lambda"
  role = aws_iam_role.stepfn_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.find_latest.arn,
          aws_lambda_function.copy_file.arn
        ]
      }
    ]
  })
}

resource "aws_sfn_state_machine" "move_latest" {
  name     = "MoveLatestS3File"
  role_arn = aws_iam_role.stepfn_role.arn
  definition = jsonencode({
    StartAt = "FindLatestFile"
    States = {
      FindLatestFile = {
        Type    = "Task"
        Resource = aws_lambda_function.find_latest.arn
        Next     = "CopyFile"
      }
      CopyFile = {
        Type    = "Task"
        Resource = aws_lambda_function.copy_file.arn
        End      = true
      }
    }
  })
}
