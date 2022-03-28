variable "aws_credentials_files" {
  type        = list(string)
  description = "The file that contains the AWS credentials we will use."
}

variable "aws_profile" {
  type        = string
  description = "The name of the AWS credentials profile we will use."
}

variable "aws_region" {
  type        = string
  description = "The name of the AWS Region we'll launch into."
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the terraform state."
  default     = "terraform-state-storage-bucket-ceros-ski-app-backend"
}

