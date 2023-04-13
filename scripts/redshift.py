import boto3
import pandas as pd
import psycopg2
import os
import io
import configparser

config = configparser.ConfigParser()
config.read("/Users/gomes/Desktop/Projects/Data Engineer/8-Project/config/config.ini")

# Redshift Credentials
aws_access_key_id = config.get("redshift", "aws_access_key_id")
aws_secret_access_key = config.get("redshift", "aws_secret_access_key")
redshift_host = config.get("redshift", "redshift_host")
redshift_port = 5439
redshift_db = config.get("redshift", "redshift_db")
redshift_user = config.get("redshift", "redshift_user")
redshift_password = config.get("redshift", "redshift_password")

# Connect to Amazon S3
s3 = boto3.client('s3', aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key)

# Define input and output paths
input_bucket = 'wu8process'
input_prefix = 'process/'

# List all Parquet files in the input path
response = s3.list_objects_v2(Bucket=input_bucket, Prefix=input_prefix)

# Connect to Redshift
conn = psycopg2.connect(
    dbname=redshift_db,
    host=redshift_host,
    port=redshift_port,
    user=redshift_user,
    password=redshift_password,
)

cursor = conn.cursor()

# Create the transactions table if it does not exist
create_table_query = """
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id VARCHAR(255),
    card_number VARCHAR(255),
    card_holder VARCHAR(255),
    amount FLOAT,
    currency VARCHAR(10),
    merchant VARCHAR(255),
    timestamp TIMESTAMP
);
"""

cursor.execute(create_table_query)
conn.commit()


table_name = 'transactions'

# Define column names in your table
column_names = ['transaction_id', 'card_number', 'card_holder', 'amount', 'currency', 'merchant', 'timestamp']
columns_str = ', '.join(column_names)

for content in response['Contents']:
    file_key = content['Key']
    if file_key.endswith('.parquet'):
        # Read Parquet file from S3
        obj = s3.get_object(Bucket=input_bucket, Key=file_key)
        parquet_data = io.BytesIO(obj['Body'].read())
        df = pd.read_parquet(parquet_data)

        for index, row in df.iterrows():
            values = []
            for value in row:
                if isinstance(value, str):
                    values.append(f"'{value}'")
                elif pd.isna(value):
                    values.append('NULL')
                elif isinstance(value, pd.Timestamp):
                    values.append(f"'{value.strftime('%Y-%m-%d %H:%M:%S')}'")
                else:
                    values.append(str(value))

            values_str = ', '.join(values)
            insert_query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({values_str})"
            cursor.execute(insert_query)
            conn.commit()

# Close Redshift connection
cursor.close()
conn.close()