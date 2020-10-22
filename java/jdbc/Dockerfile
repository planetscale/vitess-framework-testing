FROM openjdk:12

ENV VERSION "8.0.22"
ENV CONNECTOR_NAME="mysql-connector-java-${VERSION}"
ENV JAR_NAME="${CONNECTOR_NAME}.jar"
ENV CONNECTOR_CLASSPATH="/var/lib/java/${CONNECTOR_NAME}"

RUN mkdir -p /var/lib/java
RUN curl -o /tmp/$CONNECTOR_NAME.tar.gz https://cdn.mysql.com//Downloads/Connector-J/$CONNECTOR_NAME.tar.gz
RUN tar -xzvf /tmp/$CONNECTOR_NAME.tar.gz
RUN mv $CONNECTOR_NAME/$JAR_NAME $CONNECTOR_CLASSPATH

ENTRYPOINT ["/src/compile"]
