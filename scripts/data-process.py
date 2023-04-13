from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, FloatType, TimestampType

def main():
    spark = SparkSession.builder \
        .appName("JSON to Parquet Converter") \
        .getOrCreate()

    # Define input and output paths
    raw_bucket = "wu8raw"
    processed_bucket = "wu8process"
    output_path = f"s3://{processed_bucket}/process/"

    # Define the schema
    transaction_schema = StructType([
        StructField("transaction_id", StringType(), True),
        StructField("card_number", StringType(), True),
        StructField("card_holder", StringType(), True),
        StructField("amount", FloatType(), True),
        StructField("currency", StringType(), True),
        StructField("merchant", StringType(), True),
        StructField("timestamp", TimestampType(), True)
    ])

    # Read JSON data from the raw bucket
    df = (spark.read
      .format("json")
      .schema(transaction_schema)
      .option("recursiveFileLookup", "true")  # Read from all subdirectories
      .load(f"s3://{raw_bucket}/"))

    # Write data to Parquet format in the processed bucket
    df.write \
        .format("parquet") \
        .mode("overwrite") \
        .save(output_path)

if __name__ == "__main__":
    main()
