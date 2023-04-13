locals {
  processed_bucket = "wu8process"
}

resource "aws_glue_catalog_database" "athena_database" {
  name = "my_athena_database"
}

resource "aws_glue_catalog_table" "transactions" {
  name          = "transactions"
  database_name = aws_glue_catalog_database.athena_database.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "parquet"
  }

  storage_descriptor {
    location      = "s3://${local.processed_bucket}/process/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "transaction_id"
      type = "string"
    }

    columns {
      name = "card_number"
      type = "string"
    }

    columns {
      name = "card_holder"
      type = "string"
    }

    columns {
      name = "amount"
      type = "float"
    }

    columns {
      name = "currency"
      type = "string"
    }

    columns {
      name = "merchant"
      type = "string"
    }

    columns {
      name = "timestamp"
      type = "timestamp"
    }
  }
}
