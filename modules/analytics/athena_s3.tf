resource "random_pet" "this" {}

resource "aws_s3_bucket" "athena_results" {
  bucket = "athena-query-results-${random_pet.this.id}"
  force_destroy = true

  tags = {
    Name = "Athena Query Results"
  }
}

output "athena_results_bucket" {
  value = aws_s3_bucket.athena_results.bucket
}

output "athena_results_bucket_arn" {
  value = aws_s3_bucket.athena_results.arn
}