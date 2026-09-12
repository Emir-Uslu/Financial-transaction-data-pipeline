from pathlib import Path
import csv
import random
from datetime import date, timedelta
from config import BASE_DIR

random.seed(42)

DATA_DIR = BASE_DIR / "data" / "raw"
DATA_DIR.mkdir(parents=True, exist_ok=True)

FIRST_NAMES = [
    "Emir", "Asli", "Emre", "Doğan", "Halim", "Sinan", "Fatmanur", "Elif",
    "Ceyhun", "Emirhan", "Ayse", "Fatih", "Kerem", "Selin", "Berk"
]

LAST_NAMES = [
    "Uslu", "Taş", "Seker", "Ayhan", "Günes", "Ermis", "Sager",
    "Çakar", "Efe", "Ülgü", "Arpacik", "Eren", "Tas"
]

CITIES = ["Istanbul", "Ankara", "Izmir", "Bursa", "Antalya", "KahramanMaraş"]

MERCHANT_CATEGORIES = [
    "Grocery", "Electronics", "Restaurant", "Doctor",
    "Travel", "Fuel", "Pharmacy"
]

TRANSACTION_TYPES = ["purchase", "refund", "transfer"]


def random_date(start_date, end_date):
    day_count = (end_date - start_date).days
    return start_date + timedelta(days=random.randint(0, day_count))


def write_csv(filename, rows):
    path = DATA_DIR / filename
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


def build_customers():
    rows = []

    for customer_id in range(1, 1001):
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)

        rows.append({
            "customer_id": customer_id,
            "full_name": f"{first_name} {last_name}",
            "email": (
                ""
                if customer_id % 17 == 0
                else f"{first_name.lower()}.{last_name.lower()}{customer_id}@example.com"
            ),
            "city": random.choice(CITIES),
            "signup_date": random_date(
                date(2024, 1, 1),
                date(2026, 8, 31)
            ).isoformat(),
        })

    return rows


def build_merchants():
    rows = []

    for merchant_id in range(1, 101):
        rows.append({
            "merchant_id": merchant_id,
            "merchant_name": f"Merchant {merchant_id:03d}",
            "category": random.choice(MERCHANT_CATEGORIES),
            "city": random.choice(CITIES),
            "country": "Turkey",
        })

    return rows


def build_transactions():
    rows = []

    for transaction_id in range(1, 20001):
        rows.append({
            "transaction_id": transaction_id,
            "customer_id": random.randint(1, 1000),
            "merchant_id": random.randint(1, 100),
            "transaction_date": random_date(
                date(2025, 1, 1),
                date(2026, 9, 1)
            ).isoformat(),
            "amount": round(random.uniform(20, 7000), 2),
            "currency": "TRY",
            "transaction_type": random.choice(TRANSACTION_TYPES),
        })

    # Invalid references used to verify data-quality rules.
    for transaction_id in range(20001, 20011):
        rows.append({
            "transaction_id": transaction_id,
            "customer_id": 9000 + transaction_id,
            "merchant_id": random.randint(1, 100),
            "transaction_date": random_date(
                date(2025, 1, 1),
                date(2026, 9, 1)
            ).isoformat(),
            "amount": round(random.uniform(20, 1000), 2),
            "currency": "TRY",
            "transaction_type": "purchase",
        })

    # Invalid amounts used to verify validation logic.
    for transaction_id in range(20011, 20021):
        rows.append({
            "transaction_id": transaction_id,
            "customer_id": random.randint(1, 1000),
            "merchant_id": random.randint(1, 100),
            "transaction_date": random_date(
                date(2025, 1, 1),
                date(2026, 9, 1)
            ).isoformat(),
            "amount": -round(random.uniform(20, 1000), 2),
            "currency": "TRY",
            "transaction_type": "purchase",
        })

    # Duplicate transaction IDs used to verify duplicate detection.
    rows.extend(rows[100:105])

    return rows


def main():
    customers = build_customers()
    merchants = build_merchants()
    transactions = build_transactions()

    write_csv("customers.csv", customers)
    write_csv("merchants.csv", merchants)
    write_csv("transactions.csv", transactions)

    print(f"customers: {len(customers)}")
    print(f"merchants: {len(merchants)}")
    print(f"transactions: {len(transactions)}")


if __name__ == "__main__":
    main()
