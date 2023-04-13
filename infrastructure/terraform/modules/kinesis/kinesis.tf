resource "aws_kinesis_stream" "example" {
  name             = "wu8-kinesis-stream"
  shard_count      = 1
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "firehose_delivery_policy" {
  name        = "your-firehose-delivery-policy"
  description = "Policy for Kinesis Firehose to access Kinesis Data Stream and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards",
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "example" {
  name        = "wu8-firehose-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = module.s3.first_data_lake_bucket_arn
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.example.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}

resource "aws_iam_policy_attachment" "firehose_delivery_policy_attachment" {
  name       = "firehose-delivery-policy-attachment"
  roles      = [aws_iam_role.firehose_role.name]
  policy_arn = aws_iam_policy.firehose_delivery_policy.arn
}

module "s3" {
  source = "../s3"
}