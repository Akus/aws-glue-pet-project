resource "aws_glue_catalog_database" "pet_adoption_db" {
  name = "pet_adoption_db_${replace(var.bucket_name, "-", "")}"
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