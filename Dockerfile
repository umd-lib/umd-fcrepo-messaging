# Dockerfile for the generating the fcrepo-messaging Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/fcrepo-messaging:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.
FROM maven:3-eclipse-temurin-25 AS dependencies

RUN mkdir -p /var/jars
COPY pom.xml /var/jars
WORKDIR /var/jars

# fetch JARs required for running the Camel routes
RUN mvn validate dependency:copy-dependencies

FROM eclipse-temurin:25

ENV ACTIVEMQ_VERSION=6.3.2
ENV ACTIVEMQ_URL=https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz

RUN apt-get update && apt-get install -y curl

# Download and install ActiveMQ.
# We need to run this as three separate commands instead of a single
# "curl ... | tar xvzf - ..." pipeline due to some problems with how
# QEMU handles pipes and sub-processes when running multi-platform
# Docker builds on Kubernetes.
RUN curl -Ls "$ACTIVEMQ_URL" -o /tmp/activemq.tar.gz
RUN gzip -d /tmp/activemq.tar.gz
RUN tar xvf /tmp/activemq.tar --directory /opt
RUN rm /tmp/activemq.tar

ENV ACTIVEMQ_HOME=/opt/apache-activemq-${ACTIVEMQ_VERSION}
ENV ACTIVEMQ_DATA=/var/opt/activemq
ENV ACTIVEMQ_MAX_DISK=16G

COPY --from=dependencies /var/jars/target/dependency/*.jar $ACTIVEMQ_HOME/lib/optional/

COPY activemq/conf/ $ACTIVEMQ_HOME/conf/
#COPY activemq/env $ACTIVEMQ_HOME/bin/env
#COPY amistuck.sh $ACTIVEMQ_HOME/bin/amistuck.sh

VOLUME /var/opt/activemq
VOLUME /var/log/fixity

# STOMP
EXPOSE 61613
# OpenWire
EXPOSE 61616
# HTTP admin console
EXPOSE 8161
# JMX
EXPOSE 11099

WORKDIR $ACTIVEMQ_HOME
CMD ["bin/activemq", "console"]
