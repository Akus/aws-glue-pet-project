variable "bucket_name" {
  description = "The S3 bucket containing the output Parquet data."
  type        = string
}

variable "output_prefix" {
  description = "S3 prefix for the output data."
  type        = string
  default     = "output/"
  
}