# Terraform - Remote State

This module creates AWS resources to securely store terraform state:
- S3 bucket with versioning and encryption-at-rest enabled
- DynamoDB table to enforce locking when accessing remote S3 state files

Note that this only needs to be run once as part of repo setup.  After running `terraform init` then `terraform apply` to create the resources, make note of the outputs and add to any terraform backend configurations.


   
