/******************************************************************************
* Terraform Backend
*
* Create S3 Bucket and DynamoDB table
* Stores the state as a given key in a given bucket on Amazon S3.
* This storage also supports state locking and consistency checking via Dynamo DB
* for the backend.
*
* *****************************************************************************/

# S3 bucket for storage
resource "aws_s3_bucket" "terraform-state-storage-s3-ceros" {
  bucket = var.bucket_name
}
# S3 bucket ACL 
resource "aws_s3_bucket_acl" "storage-ceros-acl" {
  bucket = aws_s3_bucket.terraform-state-storage-s3-ceros.id
  acl    = "private"
}
# S3 bucket versioning to keep track of version
resource "aws_s3_bucket_versioning" "storage-versioning" {
  bucket = aws_s3_bucket.terraform-state-storage-s3-ceros.id

  versioning_configuration {
    status = "Enabled"
  }
}

# create a dynamodb table for state locking
resource "aws_dynamodb_table" "terraform-state-lock-ceros" {
  name           = "terraform-state-lock-dynamo-ceros"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for ceros"
  }
}
