#!/bin/bash

echo "Waiting for Kafka Connect to be ready..."
while ! curl -f -s http://localhost:8083/connectors > /dev/null; do
    echo "Kafka Connect is not ready yet. Waiting..."
    sleep 5
done

echo "Kafka Connect is ready!"

echo "Deploying initial Debezium MySQL connector..."
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
  http://localhost:8083/connectors/ \
  -d @initial-connector.json

echo ""
echo "Connector deployed! Checking status..."
sleep 5

curl -s http://localhost:8083/connectors/inventory-connector/status | jq '.'

echo ""
echo "Available connectors:"
curl -s http://localhost:8083/connectors | jq '.'

echo ""
echo "Initial connector is now capturing changes from customers and products tables."
echo "You can monitor topics at http://localhost:8080"
