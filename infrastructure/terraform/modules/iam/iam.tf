# IAM Role
resource "aws_iam_role" "service_role" {
  name = "your-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "s3.amazonaws.com",
            "glue.amazonaws.com",
            "ecs-tasks.amazonaws.com",
            "redshift.amazonaws.com",
            "athena.amazonaws.com",
          ]
        }
      }
    ]
  })
}

# IAM Policy
resource "aws_iam_policy" "service_policy" {
  name        = "your-service-policy"
  description = "Policy for Real-time Fraud Detection services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "glue:*",
          "ecs:*",
          "redshift:*",
          "athena:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_policy_attachment" "service_policy_attachment" {
  name       = "your-service-policy-attachment"
  roles      = [aws_iam_role.service_role.name]
  policy_arn = aws_iam_policy.service_policy.arn
}

resource "aws_iam_role" "glue_service_role" {
  name = "AWSGlueServiceRoleDefault"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "glue_service_policy" {
  name        = "AWSGlueServicePolicy"
  description = "Policy for AWS Glue service role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:*",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_service_policy_attachment" {
  name       = "AWSGlueServicePolicyAttachment"
  roles      = [aws_iam_role.glue_service_role.name]
  policy_arn = aws_iam_policy.glue_service_policy.arn
}
