from confluent_kafka import Producer
import logging
import json
import random
import time

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('KafkaProducer')

# Kafka broker address
bootstrap_servers = 'localhost:9092'

# Kafka topic to produce messages to
topic = 'topic_test'

# Configuration for the Kafka producer
conf = {
    'bootstrap.servers': bootstrap_servers,
    'client.id': 'python-producer'
}

# Create a Kafka producer instance
producer = Producer(conf)

# Acknowledge
def delivery_report(err, msg):
    if err is not None:
        logger.error(f'Message delivery failed: {err}')
    else:
        logger.info(f'Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}')

# Produce random JSON data continuously
def generate_random_json_data():
    while True:
        # Generate random data
        random_data = {
            "id": random.randint(1, 100),
            "value": f"RandomValue_{random.random()}",
            "timestamp": time.time()
        }

        # Serialize the data to JSON
        json_data = json.dumps(random_data)

        # Produce the JSON data to Kafka
        producer.produce(topic, value=json_data.encode('utf-8'), callback=delivery_report)
        logger.info(f"Produced: {json_data}")

        # Sleep for a while before producing the next message
        time.sleep(10)

# Start producing random JSON data
generate_random_json_data()