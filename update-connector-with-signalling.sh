#!/bin/bash

echo "Step 1: Update connector configuration to include new tables..."
curl -i -X PUT -H "Accept:application/json" -H "Content-Type:application/json" \
  http://localhost:8083/connectors/inventory-connector/config \
  -d @updated-connector.json

echo ""
echo "Waiting for connector to restart..."
sleep 10

echo "Step 2: Check connector status after update..."
curl -s http://localhost:8083/connectors/inventory-connector/status | jq '.'

echo ""
echo "Step 3: Trigger incremental snapshot for new tables using signalling..."

# Generate unique signal ID
SIGNAL_ID=$(date +%s)

# Insert signal to trigger incremental snapshot for new tables
docker exec -it mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
INSERT INTO debezium_signal (id, type, data) VALUES 
('snapshot-${SIGNAL_ID}', 'execute-snapshot', '{\"data-collections\": [\"inventory.orders\", \"inventory.order_items\"], \"type\": \"incremental\"}');
"

echo ""
echo "Signal sent! The incremental snapshot will:"
echo "1. Capture existing data from orders and order_items tables"
echo "2. Ensure no replay of messages from customers and products tables"
echo "3. Continue capturing real-time changes from all tables"

echo ""
echo "You can monitor the progress by:"
echo "1. Checking Kafka topics at http://localhost:8080"
echo "2. Watching connector logs: docker logs -f connect"
echo "3. Checking signal processing: docker exec -it mysql mysql -u mysqluser -pmysqlpw -D inventory -e 'SELECT * FROM debezium_signal;'"
