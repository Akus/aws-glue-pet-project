
resource "aws_iam_role" "glue_crawler_role" {
  name = "glue-crawler-role-${replace(var.bucket_name, "-", "")}"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_assume.json
}

data "aws_iam_policy_document" "glue_crawler_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "glue_crawler_policy_s3_attach" {
  role = aws_iam_role.glue_crawler_role.id
  policy = data.aws_iam_policy_document.glue_crawler_policy_s3.json
}

data "aws_iam_policy_document" "glue_crawler_policy_s3" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
  statement {
    actions = [
      "glue:GetTable",
      "glue:GetTables",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:GetDatabase",
      "glue:CreateDatabase"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "glue_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:eu-central-1:823514127427:log-group:/aws-glue/*"
    ]
  }
}

resource "aws_iam_role_policy" "glue_logs_attach" {
  name = "AllowGlueToWriteLogs"
  role = aws_iam_role.glue_crawler_role.id
  policy = data.aws_iam_policy_document.glue_logs.json
}