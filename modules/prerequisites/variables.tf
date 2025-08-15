variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
}

variable "etl_script_file" {
  description = "Path to the ETL script template file."
  type        = string
}

variable "csv_file" {
  description = "Path to the sample CSV file."
  type        = string
}