# Glue Modular Demo

This project demonstrates a modular approach to deploying AWS Glue ETL pipelines using Terraform. It provisions the necessary AWS infrastructure, including S3 buckets, Glue jobs, and related resources, in a reusable and maintainable manner.

---

## Features

- **Modular Terraform Structure**: Clean separation of concerns using modules (`prerequisites` and `analytics`).
- **S3 Buckets**: Stores input data and ETL scripts.
- **AWS Glue ETL Job**: Processes CSV data and outputs Parquet files.
- **AWS Glue Crawler**: Automatically catalogs the transformed data.

---

## Project Structure

```
.
├── main.tf                        # Root Terraform configuration
├── variables.tf                   # Input variables
├── outputs.tf                     # Outputs from the deployment
├── pet_adoption_etl.py.tmpl       # Templated ETL script (rendered by Terraform)
├── pet_adoptions.csv              # Example input data
├── modules/
│   ├── prerequisites/             # Sets up S3, IAM, Glue job, uploads scripts/data
│   └── analytics/                 # Sets up Glue crawler
└── README.md                      # This file
```

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with sufficient permissions (S3, Glue, IAM)
- Python 3.x (for local script testing, optional)

---

## Deployment Steps

1. **Clone the Repository**
    ```sh
    git clone https://github.com/your-username/glue-modular-demo.git
    cd glue-modular-demo
    ```

2. **Initialize Terraform**
    ```sh
    terraform init
    ```

3. **Review and (Optionally) Edit Variables**
    - Open `variables.tf` and update any variables as needed (such as AWS region).

4. **Plan the Deployment**
    ```sh
    terraform plan
    ```

5. **Apply the Deployment**
    ```sh
    terraform apply
    ```
    - Confirm with `yes` when prompted.

6. **Outputs**
    - After deployment, Terraform will output useful information such as:
      - The S3 bucket name
      - The Glue job name and role ARN
      - The Glue crawler name

---

## How It Works

- The `prerequisites` module sets up the S3 bucket, uploads the ETL script and CSV input, and provisions the Glue job.
- The `analytics` module creates the Glue crawler to catalog Parquet data.
- The ETL job transforms the input CSV into Parquet format and writes it to the output location.
- The Glue crawler updates the Data Catalog with the schema of the output data.
- The Athena S3 bucket will store the Athena query results

---

## Cleaning Up

To destroy all resources provisioned by this project:
```sh
terraform destroy
```
**Warning:** This will delete all S3 buckets, Glue jobs, and crawlers created by this deployment.

---

## Troubleshooting

- **Glue Table Errors:**  
  If you see errors about data type mismatches, ensure your ETL script writes columns with the correct types as expected by your Glue table schema.
- **S3 Bucket Already Exists:**  
  S3 bucket names must be globally unique. If you get an error, change the bucket name variable.
- **Glue Job Already Exists:**  
  Import the existing resource into Terraform state, or change the name in your configuration.

---

## License

MIT License

---

## Authors

- [Akos Bodor](https://github.com/Akus)