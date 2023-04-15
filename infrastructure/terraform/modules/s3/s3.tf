resource "aws_s3_bucket" "buckets-for-data-lake" {
  for_each = { for idx, bucket in var.bucket_datalake : idx => bucket }
  bucket = each.value
}

resource "aws_s3_bucket" "buckets-for-glue-script" {
  bucket = var.bucket_glue
}

resource "aws_s3_bucket_object" "data_process" {
  bucket = aws_s3_bucket.buckets-for-glue-script.id
  key    = "glue_scripts/data-process.py"
  acl    = "private"
  source = "../../scripts/data-process.py"
}

# resource "aws_s3_bucket_object" "process_data_folder" {
#   bucket       = aws_s3_bucket.buckets-for-data-lake[0].id
#   key          = "raw/"
#   acl          = "private"
#   content_type = "application/x-directory"
# }


resource "aws_s3_bucket_object" "process_data_folder" {
  bucket       = aws_s3_bucket.buckets-for-data-lake[1].id
  key          = "process/"
  acl          = "private"
  content_type = "application/x-directory"
}

variable "bucket_datalake" {
  type = list(string)
  description = "name of the buckets for datalake"
  default = ["wu8raw", "wu8process"]
}

variable "bucket_glue" {
  type = string
  description = "name of the bucket for glue"
  default = "wu8-glue-job"
}

output "first_data_lake_bucket_name" {
  value = aws_s3_bucket.buckets-for-data-lake[0].bucket
}

output "first_data_lake_bucket_arn" {
  value = aws_s3_bucket.buckets-for-data-lake[0].arn
}
