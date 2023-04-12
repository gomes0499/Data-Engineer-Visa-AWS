import json
from faker import Faker
from confluent_kafka import Producer

fake = Faker()


# Kafka configuration
KAFKA_BOOTSTRAP_SERVERS = "your_kafka_bootstrap_servers"
KAFKA_TOPIC = "your_kafka_topic"

# Initialize the Kafka producer
producer_conf = {"bootstrap.servers": KAFKA_BOOTSTRAP_SERVERS}
producer = Producer(producer_conf)

def kafka_producer_on_delivery(err, msg):
    if err is not None:
        print(f"Failed to deliver message: {err}")
    else:
        print(f"Produced message to {msg.topic()} [{msg.partition()}] @ {msg.offset()}")

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
        producer.produce(KAFKA_TOPIC, key=transaction["transaction_id"], value=json.dumps(transaction), callback=kafka_producer_on_delivery)
    producer.flush()

if __name__ == "__main__":
    produce_transactions()
