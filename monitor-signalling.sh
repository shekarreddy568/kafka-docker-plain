#!/bin/bash

echo "=== Debezium Signalling Monitor ==="
echo ""

echo "1. Connector Status:"
curl -s http://localhost:8083/connectors/inventory-connector/status | jq '.connector.state, .tasks[0].state'

echo ""
echo "2. Signal Table Contents:"
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "SELECT * FROM debezium_signal ORDER BY id DESC LIMIT 5;"

echo ""
echo "3. Available Kafka Topics:"
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list | grep dbserver1

echo ""
echo "4. Recent Messages Count in Topics:"
for topic in $(docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list | grep dbserver1); do
    count=$(docker exec kafka kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic $topic --time -1 | awk -F: '{sum += $3} END {print sum}')
    echo "$topic: $count messages"
done

echo ""
echo "5. Connector Tasks:"
curl -s http://localhost:8083/connectors/inventory-connector/tasks | jq '.'

echo ""
echo "Monitor complete. Run this script periodically to track progress."
