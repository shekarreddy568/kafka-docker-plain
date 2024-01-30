
from confluent_kafka import Consumer, KafkaError
import logging
import json

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('KafkaConsumer')

# Kafka broker address
bootstrap_servers = 'localhost:9092'

# Kafka topic to consume messages from
topic = 'topic_test'

# Consumer group ID
group_id = 'test_consumer_group'

# Configuration for the Kafka consumer
conf = {
    'bootstrap.servers': bootstrap_servers,
    'group.id': group_id,
    'auto.offset.reset': 'earliest'
}

# Create a Kafka consumer instance
consumer = Consumer(conf)

# Subscribe to the Kafka topic
consumer.subscribe([topic])

# Consume messages continuously
try:
    while True:
        msg = consumer.poll(1.0)

        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                # End of partition event
                continue
            else:
                # Handle other errors
                logger.error(f'Error: {msg.error()}')
                break

        # Print the consumed message value
        logger.info(f"Consumed: {msg.value().decode('utf-8')}")

except KeyboardInterrupt:
    pass
finally:
    # Close down consumer to commit final offsets.
    consumer.close()
