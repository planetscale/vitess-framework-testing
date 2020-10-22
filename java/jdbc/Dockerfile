FROM openjdk:12

ENV CONNECTOR_CLASSPATH="/var/lib/java/mysql-connector-java-8.0.22.jar"

RUN mkdir -p /var/lib/java
RUN curl -o /tmp/mysql-connector-java-8.0.22.tar.gz https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-8.0.22.tar.gz
RUN tar -xzvf /tmp/mysql-connector-java-8.0.22.tar.gz
RUN ls /tmp
RUN mv mysql-connector-java-8.0.22/mysql-connector-java-8.0.22.jar $CONNECTOR_CLASSPATH

ENTRYPOINT ["/src/compile"]
