import json
import configparser
from faker import Faker
import boto3
import time


fake = Faker()
config = configparser.ConfigParser()
config.read("/Users/gomes/Desktop/Projects/Data Engineer/8-Project/config/config.ini")

# Kinesis configuration
KINESIS_STREAM_NAME = config.get("kinesis", "KINESIS_STREAM_NAME")

# Initialize the Kinesis client
kinesis_client = boto3.client("kinesis")

def generate_transaction():
    transaction = {
        "transaction_id": fake.uuid4(),
        "card_number": fake.credit_card_number(card_type="visa"),
        "card_holder": fake.name(),
        "amount": round(fake.random.uniform(1, 1000), 2),
        "currency": "USD",
        "merchant": fake.company(),
        "timestamp": fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S")
    }
    return transaction

def generate_transactions(num_transactions=1):
    transactions = []
    for _ in range(num_transactions):
        transactions.append(generate_transaction())
    return transactions

def produce_transactions(num_transactions=1):
    transactions = generate_transactions(num_transactions)
    for transaction in transactions:
        response = kinesis_client.put_record(
            StreamName=KINESIS_STREAM_NAME,
            Data=json.dumps(transaction),
            PartitionKey=transaction["transaction_id"],
        )
        print(f"PutRecord response: {response}")

if __name__ == "__main__":
    while True:
        produce_transactions(1)
        time.sleep(1)
