FROM confluentinc/cp-kafka-connect-base:7.3.1

ENV KAFKA_OPTS="-Doracle.jdbc.timezoneAsRegion=false"

# RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:latest
# RUN confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.7.0
# RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:1.9.3
# RUN confluent-hub install --no-prompt debezium/debezium-connector-sqlserver:1.8.1
# RUN confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:latest
# RUN confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:latest
# RUN confluent-hub install --no-prompt confluentinc/kafka-connect-salesforce:latest
# RUN confluent-hub install --no-prompt confluentinc/kafka-connect-ibmmq:latest
# RUN confluent-hub install --no-prompt confluentinc/kafka-connect-ibmmq-sink:latest
# RUN confluent-hub install --no-prompt confluentinc/kafka-connect-cassandra:latest
RUN confluent-hub install --no-prompt jcustenborder/kafka-connect-spooldir:latest

COPY jars/kafkaconnect-rest-extension_3-0.1.0-SNAPSHOT.jar /usr/share/confluent-hub-components/kafkaconnect-rest-extension_3-0.1.0-SNAPSHOT.jar

# COPY jars/ibmmq/wmq/JavaSE/lib/ /usr/share/confluent-hub-components/confluentinc-kafka-connect-ibmmq/lib/
# COPY jars/ibmmq/wmq/JavaSE/lib/ /usr/share/confluent-hub-components/confluentinc-kafka-connect-ibmmq-sink/lib/

# COPY jars/ojdbc7-12.1.0.2.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/ojdbc7-12.1.0.2.jar
# COPY jars/mssql-jdbc-8.4.0.jre8.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/mssql-jdbc-8.4.0.jre8.jar
# COPY jars/mysql-connector-java-5.1.23.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/mysql-connector-java-5.1.23.jar
# COPY jars/kafka-connect-salesforce-0.3-SNAPSHOT.tar.gz /tmp
# RUN  tar -xvzf /tmp/kafka-connect-salesforce-0.3-SNAPSHOT.tar.gz