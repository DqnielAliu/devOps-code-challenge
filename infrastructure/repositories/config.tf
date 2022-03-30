provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = var.aws_credentials_files
  profile                  = var.aws_profile
}

terraform {
  required_version = ">= 0.14.4"

  backend "s3" {
    bucket         = "terraform-state-storage-bucket-ceros-ski-app-backend"
    key            = "global/ceros_state/repositories/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock-dynamo-ceros"
    encrypt        = true
  }
}
