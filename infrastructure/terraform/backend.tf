# Configure the backend to store state in S3
terraform {
  backend "s3" {
    bucket = "8tf-state"
    key = "tfstate"
    region = "us-east-1"
  }
}