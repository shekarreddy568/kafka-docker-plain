# Debezium MySQL CDC with Kafka KRaft and Signalling - Complete Guide

This comprehensive guide demonstrates how to set up a complete Debezium MySQL CDC pipeline with Kafka KRaft (no Zookeeper) and use the signalling mechanism to add new tables without replaying existing data.

## 🎯 What This Demonstrates

- **Kafka KRaft Mode**: Running Kafka without Zookeeper dependency
- **Initial CDC Setup**: Capturing changes from initial set of tables
- **Dynamic Table Addition**: Adding new tables to existing connector using signalling
- **No Data Replay**: Ensuring existing tables don't replay data when new tables are added
- **Incremental Snapshots**: Capturing existing data from new tables only
- **Real-time CDC**: Continuous change data capture for all tables

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MySQL 8.0     │    │  Kafka KRaft    │    │  Kafka Connect  │
│   (Source DB)   │───▶│   (Broker)      │───▶│   (Debezium)    │
│   + Binlog      │    │   + Topics      │    │   + Signalling  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Signal Table    │    │   Kafka UI      │    │   CDC Topics    │
│ (debezium_      │    │  (Monitoring)   │    │  (Data Stream)  │
│  signal)        │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

- Docker and Docker Compose installed
- Basic understanding of Kafka, MySQL, and CDC concepts
- `curl` and `jq` for API interactions (optional but recommended)

## 🚀 Quick Start

### Step 1: Clone or Create Project Structure

```bash
mkdir debezium-kafka-kraft-signalling
cd debezium-kafka-kraft-signalling
```

### Step 2: Start the Environment

```bash
# Start all services
docker compose up -d

# Verify all services are healthy
docker compose ps
```

Expected output:
```
NAME       IMAGE                           STATUS
connect    debezium/connect:2.4            Up (healthy)
kafka      apache/kafka:3.7.0              Up (healthy)
kafka-ui   provectuslabs/kafka-ui:latest   Up
mysql      mysql:8.0                       Up (healthy)
```

### Step 3: Deploy Initial Connector

```bash
# Deploy connector for initial tables (customers, products)
chmod +x deploy-initial-connector.sh
./deploy-initial-connector.sh
```

### Step 4: Verify Initial Setup

- Open Kafka UI: http://localhost:8080
- Check topics: `dbserver1.inventory.customers` and `dbserver1.inventory.products`
- Verify initial data is captured

### Step 5: Add New Tables with Signalling

```bash
# Add orders and order_items tables without replaying existing data
chmod +x update-connector-with-signalling.sh
./update-connector-with-signalling.sh
```

### Step 6: Test Real-time CDC

```bash
# Test with sample data changes
chmod +x test-cdc-changes.sh
./test-cdc-changes.sh
```

### Step 7: Monitor the Process

```bash
# Monitor signalling and connector status
chmod +x monitor-signalling.sh
./monitor-signalling.sh
```

## 📁 Complete File Structure

```
debezium-kafka-kraft-signalling/
├── docker-compose.yml                    # Main orchestration file
├── mysql-init/
│   └── 01-init.sql                      # Database initialization
├── initial-connector.json               # Initial connector config
├── updated-connector-config.json        # Updated connector config
├── deploy-initial-connector.sh          # Deploy initial connector
├── update-connector-with-signalling.sh  # Add tables with signalling
├── test-cdc-changes.sh                  # Test CDC functionality
├── monitor-signalling.sh                # Monitor the process
├── README.md                            # This comprehensive guide
└── VERIFICATION_SUMMARY.md              # Results summary
```

## 📝 Step-by-Step Detailed Process

### Phase 1: Environment Setup

#### 1.1 Create Project Directory
```bash
mkdir debezium-kafka-kraft-signalling
cd debezium-kafka-kraft-signalling
```

#### 1.2 Create All Configuration Files
Create all the files as shown in the file structure above.

#### 1.3 Start Services
```bash
docker compose up -d
```

#### 1.4 Verify Services Health
```bash
# Check all services are running
docker compose ps

# Check individual service logs if needed
docker compose logs kafka
docker compose logs mysql
docker compose logs connect
```

### Phase 2: Initial Connector Deployment

#### 2.1 Wait for Services to be Ready
```bash
# Wait for Kafka Connect to be ready
while ! curl -f -s http://localhost:8083/connectors > /dev/null; do
    echo "Waiting for Kafka Connect..."
    sleep 5
done
```

#### 2.2 Deploy Initial Connector
```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
  http://localhost:8083/connectors/ \
  -d @initial-connector.json
```

#### 2.3 Verify Initial Connector
```bash
# Check connector status
curl -s http://localhost:8083/connectors/inventory-connector/status | jq '.'

# List available topics
docker exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list

# Check initial data capture
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.customers \
  --from-beginning --max-messages 3
```

Expected topics after initial setup:
- `dbserver1.inventory.customers`
- `dbserver1.inventory.products`
- `dbserver1.inventory.debezium_signal`

### Phase 3: Adding New Tables with Signalling

#### 3.1 Update Connector Configuration
```bash
curl -i -X PUT -H "Accept:application/json" -H "Content-Type:application/json" \
  http://localhost:8083/connectors/inventory-connector/config \
  -d @updated-connector-config.json
```

#### 3.2 Verify Configuration Update
```bash
# Check connector is still running
curl -s http://localhost:8083/connectors/inventory-connector/status | jq '.connector.state'

# Verify new table list in configuration
curl -s http://localhost:8083/connectors/inventory-connector/config | jq '.["table.include.list"]'
```

#### 3.3 Trigger Incremental Snapshot via Signalling
```bash
# Generate unique signal ID
SIGNAL_ID=$(date +%s)

# Insert signal to trigger incremental snapshot
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
INSERT INTO debezium_signal (id, type, data) VALUES 
('snapshot-${SIGNAL_ID}', 'execute-snapshot', 
 '{\"data-collections\": [\"inventory.orders\", \"inventory.order_items\"], \"type\": \"incremental\"}');
"
```

#### 3.4 Monitor Signal Processing
```bash
# Check signal table
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "SELECT * FROM debezium_signal;"

# Check new topics are created
docker exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list | grep -E "(orders|order_items)"

# Verify incremental snapshot data
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.orders \
  --from-beginning --max-messages 3
```

### Phase 4: Verification of No Data Replay

#### 4.1 Count Messages in Original Tables
```bash
# Count customers messages (should remain 3)
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.customers \
  --from-beginning | wc -l

# Count products messages (should remain 3)
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.products \
  --from-beginning | wc -l
```

#### 4.2 Verify New Table Data
```bash
# Check orders data (should have 3 messages with "__op":"r")
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.orders \
  --from-beginning --max-messages 3

# Check order_items data (should have 5 messages with "__op":"r")
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.order_items \
  --from-beginning --max-messages 5
```

### Phase 5: Real-time CDC Testing

#### 5.1 Test INSERT Operations
```bash
# Add new customer
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
INSERT INTO customers (first_name, last_name, email) VALUES ('Alice', 'Brown', 'alice.brown@example.com');
"

# Add new order
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
INSERT INTO orders (customer_id, total_amount, status) VALUES (4, 899.99, 'pending');
"
```

#### 5.2 Test UPDATE Operations
```bash
# Update product price
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
UPDATE products SET price = 899.99, updated_at = NOW() WHERE id = 1;
"
```

#### 5.3 Verify Real-time Changes
```bash
# Check new customer (should have "__op":"c")
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.customers \
  --from-beginning | tail -1

# Check product update (should have "__op":"u")
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic dbserver1.inventory.products \
  --from-beginning | tail -1
```

## 🔍 Understanding Operation Types

### Message Operation Types (`__op` field):

- **`"r"`** - Read (from snapshot, initial or incremental)
- **`"c"`** - Create (INSERT operations)
- **`"u"`** - Update (UPDATE operations)
- **`"d"`** - Delete (DELETE operations)

### Timeline of Operations:

1. **Initial Snapshot**: `customers` and `products` tables → `"__op":"r"`
2. **Incremental Snapshot**: `orders` and `order_items` tables → `"__op":"r"`
3. **Real-time CDC**: All new changes → `"__op":"c"`, `"__op":"u"`, `"__op":"d"`

## 📊 Monitoring and Troubleshooting

### Kafka UI Dashboard
Access the web interface at http://localhost:8080 to:
- View all topics and their messages
- Monitor connector status
- Inspect message schemas
- Track consumer lag

### Command Line Monitoring

#### Check Connector Status
```bash
curl -s http://localhost:8083/connectors/inventory-connector/status | jq '.'
```

#### List All Topics
```bash
docker exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
```

#### Monitor Connector Logs
```bash
docker logs -f connect
```

#### Check MySQL Binlog Status
```bash
docker exec mysql mysql -u root -pdebezium -e "SHOW MASTER STATUS;"
```

#### View Signal Processing
```bash
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "SELECT * FROM debezium_signal ORDER BY id DESC LIMIT 10;"
```

### Common Issues and Solutions

#### Issue: Connector Fails to Start
**Solution**: Check MySQL binlog configuration
```bash
docker exec mysql mysql -u root -pdebezium -e "SHOW VARIABLES LIKE '%binlog%';"
```

#### Issue: No Messages in Topics
**Solution**: Verify table.include.list configuration
```bash
curl -s http://localhost:8083/connectors/inventory-connector/config | jq '.["table.include.list"]'
```

#### Issue: Signal Not Processed
**Solution**: Check signal table permissions and format
```bash
docker exec mysql mysql -u mysqluser -pmysqlpw -D inventory -e "DESCRIBE debezium_signal;"
```

#### Issue: Kafka Connect Not Ready
**Solution**: Wait for all dependencies
```bash
# Check health of all services
docker compose ps
```

## 🧹 Cleanup

### Stop Services
```bash
docker compose down
```

### Remove All Data (WARNING: This deletes everything)
```bash
docker compose down -v
```

### Remove Images
```bash
docker rmi apache/kafka:3.7.0 mysql:8.0 debezium/connect:2.4 provectuslabs/kafka-ui:latest
```

## 🚀 Production Considerations

### Security
- Use proper authentication for Kafka and MySQL
- Encrypt connections with SSL/TLS
- Implement proper access controls
- Store passwords in secrets management systems

### Scalability
- Use multiple Kafka brokers for high availability
- Configure appropriate replication factors
- Monitor resource usage and scale accordingly
- Implement proper partitioning strategies

### Monitoring
- Set up comprehensive monitoring with Prometheus/Grafana
- Monitor connector lag and throughput
- Set up alerts for connector failures
- Track MySQL binlog position and retention

### Backup and Recovery
- Regular backups of MySQL data
- Kafka topic backup strategies
- Connector configuration versioning
- Disaster recovery procedures

## 📚 Additional Resources

- [Debezium Documentation](https://debezium.io/documentation/)
- [Kafka KRaft Mode](https://kafka.apache.org/documentation/#kraft)
- [Debezium Signalling](https://debezium.io/documentation/reference/stable/configuration/signalling.html)
- [MySQL Binlog Configuration](https://dev.mysql.com/doc/refman/8.0/en/binary-log.html)

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: This setup is designed for development and testing. For production use, implement proper security, monitoring, and high availability configurations.
