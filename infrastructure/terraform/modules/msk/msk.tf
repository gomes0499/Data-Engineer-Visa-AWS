resource "aws_msk_cluster" "example" {
  cluster_name = "wu8kafkacluster"
  kafka_version = "2.8.0"

  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = aws_subnet.example.*.id
    security_groups = [aws_security_group.kafka.id]
    ebs_volume_size = 100
  }
}

resource "aws_mskconnect_connector" "example" {
  name = "wu8connector"

  kafkaconnect_version = "2.7.1"

  capacity {
    autoscaling {
      mcu_count        = 1
      min_worker_count = 1
      max_worker_count = 2

      scale_in_policy {
        cpu_utilization_percentage = 20
      }

      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }

  connector_configuration = {
    "connector.class"                = "io.confluent.connect.s3.S3SinkConnector"
    "tasks.max"                      = "1"
    "topics"                         = "your-topic"
    "s3.region"                      = "your-region"
    "s3.bucket.name"                 = "your-s3-bucket-name"
    "flush.size"                     = "3"
    "storage.class"                  = "io.confluent.connect.s3.storage.S3Storage"
    "format.class"                   = "io.confluent.connect.s3.format.json.JsonFormat"
    "partitioner.class"              = "io.confluent.connect.storage.partitioner.DefaultPartitioner"
    "schema.generator.class"         = "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator"
    "schema.compatibility"           = "NONE"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.example.bootstrap_brokers_tls

      vpc {
        security_groups = [aws_security_group.kafka.id]
        subnets         = aws_subnet.example[*].id
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "NONE"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.example.arn
      revision = aws_mskconnect_custom_plugin.example.latest_revision
    }
  }

  service_execution_role_arn = aws_iam_role.example.arn
}

resource "aws_s3_bucket" "example" {
  bucket = "wu8pluginkafka"
}

resource "aws_s3_object" "example" {
  bucket = aws_s3_bucket.example.id
  key    = "confluent-s3-connector.zip"
  source = "path/to/confluent-s3-connector.zip"
}

resource "aws_mskconnect_custom_plugin" "example" {
  name         = "confluent-s3-connector-example"
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = aws_s3_bucket.example.arn
      file_key   = aws_s3_object.example.key
    }
  }
}

output "bootstrap_brokers" {
  value = aws_msk_cluster.example.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  value = aws_msk_cluster.example.bootstrap_brokers_tls
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example" {
  count = 3

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.example.id
  availability_zone = "us-east-1${element(["a", "b", "c"], count.index)}"

  tags = {
    Name = "example-subnet-${count.index}"
  }
}

resource "aws_security_group" "kafka" {
  name        = "kafka-security-group"
  description = "Security group for Kafka cluster"
  vpc_id      = aws_vpc.example.id
}

resource "aws_security_group_rule" "kafka_broker" {
  security_group_id = aws_security_group.kafka.id

  type        = "ingress"
  from_port   = 9092
  to_port     = 9092
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
}

resource "aws_iam_role" "example" {
  name = "example-msk-connect-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "connect.kafka.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "example" {
  name   = "example-msk-connect-policy"
  role   = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })
}