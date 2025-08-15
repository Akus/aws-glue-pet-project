resource "aws_s3_bucket" "glue_demo" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_object" "input_csv" {
  bucket = aws_s3_bucket.glue_demo.id
  key    = "input/pet_adoptions.csv"
  source = var.csv_file
}

data "local_file" "etl_template" {
  filename = var.etl_script_file
}

data "template_file" "etl_script" {
  template = data.local_file.etl_template.content
  vars = {
    bucket = aws_s3_bucket.glue_demo.bucket
  }
}

resource "aws_s3_bucket_object" "glue_script" {
  bucket  = aws_s3_bucket.glue_demo.id
  key     = "scripts/pet_adoption_etl.py"
  content = data.template_file.etl_script.rendered
}

resource "aws_iam_role" "glue_service_role" {
  name = "glue-demo-role-${replace(var.bucket_name, "-", "")}"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
}

data "aws_iam_policy_document" "glue_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "glue_policy" {
  role = aws_iam_role.glue_service_role.id
  policy = data.aws_iam_policy_document.glue_policy.json
}

data "aws_iam_policy_document" "glue_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.glue_demo.arn,
      "${aws_s3_bucket.glue_demo.arn}/*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_glue_job" "pet_adoption_etl" {
  name     = "pet-adoption-etl-${replace(var.bucket_name, "-", "")}"
  role_arn = aws_iam_role.glue_service_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_demo.bucket}/scripts/pet_adoption_etl.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language"   = "python"
    "--TempDir"        = "s3://${aws_s3_bucket.glue_demo.bucket}/temp/"
    "--enable-metrics" = ""
  }
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
}

output "bucket_name" {
  value = aws_s3_bucket.glue_demo.bucket
}

output "glue_job_name" {
  value = aws_glue_job.pet_adoption_etl.name
}

output "glue_job_role_arn" {
  value = aws_iam_role.glue_service_role.arn
}

output "bucket_arn" {
  value = aws_s3_bucket.glue_demo.arn
}