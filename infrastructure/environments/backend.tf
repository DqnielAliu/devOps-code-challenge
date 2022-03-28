# Terraform backend to store state file remotely
terraform {
  backend "s3" {
    bucket         = "terraform-state-storage-bucket-ceros-ski-app-backend"
    key            = "global/ceros_state/environments/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock-dynamo-ceros"
    encrypt        = true
  }
}
