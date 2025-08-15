
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