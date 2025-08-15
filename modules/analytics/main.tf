resource "aws_glue_catalog_database" "pet_adoption_db" {
  name = "pet_adoption_db_${replace(var.bucket_name, "-", "")}"
}

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

resource "aws_iam_role_policy" "glue_crawler_policy" {
  role = aws_iam_role.glue_crawler_role.id
  policy = data.aws_iam_policy_document.glue_crawler_policy.json
}

data "aws_iam_policy_document" "glue_crawler_policy" {
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

resource "aws_glue_crawler" "pet_adoption_output" {
  name          = "pet-adoption-crawler-${replace(var.bucket_name, "-", "")}"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.pet_adoption_db.name

  s3_target {
    path = "s3://${var.bucket_name}/${var.output_prefix}"
  }
}


output "crawler_name" {
  value = aws_glue_crawler.pet_adoption_output.name
}

output "glue_catalog_database_name" {
  value = aws_glue_catalog_database.pet_adoption_db.name
}