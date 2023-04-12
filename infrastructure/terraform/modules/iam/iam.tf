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
            "apigateway.amazonaws.com",
            "s3.amazonaws.com",
            "glue.amazonaws.com",
            "ecs-tasks.amazonaws.com",
            "redshift.amazonaws.com",
            "kafka.amazonaws.com", 
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
          "apigateway:*",
          "glue:*",
          "ecs:*",
          "redshift:*",
          "kafka:*", 
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
