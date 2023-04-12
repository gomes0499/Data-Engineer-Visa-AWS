import json
from faker import Faker


fake = Faker()

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

if __name__ == "__main__":
    print(json.dumps(generate_transactions(), indent=2))
