output "s3_bucket_name" {
  value = aws_s3_bucket.terraform-state-storage-s3-ceros.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform-state-lock-ceros.name
}
