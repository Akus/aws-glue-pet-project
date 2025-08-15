terraform {
  required_version = ">= 1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40.0" # Use the latest stable 5.x provider
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "random_pet" "this" {}

locals {
  bucket_name = "glue-modular-demo-${random_pet.this.id}"
}

module "prerequisites" {
  source         = "./modules/prerequisites"
  bucket_name    = local.bucket_name
  etl_script_file = "${path.module}/pet_adoption_etl.py.tmpl"
  csv_file        = "${path.module}/input/pet_adoptions.csv"
}

module "analytics" {
  source       = "./modules/analytics"
  bucket_name  = module.prerequisites.bucket_name
  # output_prefix is defaulted to "output/", override if needed
}

module "automation" {
  source       = "./modules/automation"
  bucket_name  = module.prerequisites.bucket_name  
}

output "bucket_name" {
  value = module.prerequisites.bucket_name
}

output "glue_job_name" {
  value = module.prerequisites.glue_job_name
}

output "glue_job_role_arn" {
  value = module.prerequisites.glue_job_role_arn
}

output "crawler_name" {
  value = module.analytics.crawler_name
}