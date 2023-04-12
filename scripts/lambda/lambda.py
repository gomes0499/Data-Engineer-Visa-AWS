from confluent_kafka import Producer
from visaapi import generate_transactions
import json
import os

KAFKA_BOOTSTRAP_SERVERS = os.environ.get('KAFKA_BOOTSTRAP_SERVERS')
KAFKA_TOPIC = os.environ.get('KAFKA_TOPIC')

def kafka_producer_on_delivery(err, msg):
    if err is not None:
        print(f"Failed to deliver message: {err}")
    else:
        print(f"Produced message to {msg.topic()} [{msg.partition()}] @ {msg.offset()}")

def kafka_producer():
    conf = {'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS}
    return Producer(conf)

producer = kafka_producer()

def lambda_handler(event, context):
    connection_id = event["requestContext"]["connectionId"]

    if event["requestContext"]["eventType"] == "MESSAGE":
        return handle_message(connection_id, event)
    else:
        return {
            "statusCode": 200
        }

def handle_message(connection_id, event):
    message = json.loads(event["body"])
    print(f"Received message from {connection_id}: {message}")
    
    num_transactions = int(message.get("num_transactions", 1))
    transactions = generate_transactions(num_transactions)

    # Produce transactions to Kafka topic
    for transaction in transactions:
        producer.produce(KAFKA_TOPIC, key=connection_id, value=json.dumps(transaction), callback=kafka_producer_on_delivery)
    producer.flush()

    return {
        "statusCode": 200
    }

