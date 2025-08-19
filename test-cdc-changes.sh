#!/bin/bash

echo "Testing CDC with sample data changes..."

echo "1. Adding new customer (should appear in Kafka immediately)..."
docker exec -it mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
INSERT INTO customers (first_name, last_name, email) VALUES ('Alice', 'Brown', 'alice.brown@example.com');
"

echo "2. Updating product price (should appear in Kafka immediately)..."
docker exec -it mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
UPDATE products SET price = 899.99, updated_at = NOW() WHERE id = 1;
"

echo "3. Adding new order (should appear in Kafka after signalling is complete)..."
docker exec -it mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
INSERT INTO orders (customer_id, total_amount, status) VALUES (4, 899.99, 'pending');
"

echo "4. Adding order items (should appear in Kafka after signalling is complete)..."
docker exec -it mysql mysql -u mysqluser -pmysqlpw -D inventory -e "
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (4, 1, 1, 899.99);
"

echo ""
echo "Test data inserted! Check the following Kafka topics:"
echo "- dbserver1.inventory.customers"
echo "- dbserver1.inventory.products"
echo "- dbserver1.inventory.orders"
echo "- dbserver1.inventory.order_items"
echo ""
echo "Monitor at: http://localhost:8080"
