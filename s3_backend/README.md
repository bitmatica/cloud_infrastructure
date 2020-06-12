# Terraform - Remote State

This module creates AWS resources to securely store terraform state:
- S3 bucket with versioning and encryption-at-rest enabled
- DynamoDB table to enforce locking when accessing remote S3 state files

Note that `terraform.tfstate` is checked into version control (this file should usually never be checked into version control as it can contain secrets).  In this case the state file is version controlled since no secrets are present and to ensure team members don't recreate remote state resources.

As a one-time setup for this repo, run `terraform init` then `terraform apply` to create the resources.  Make note of the outputs and add to any terraform backend configurations.


   
