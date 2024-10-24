# Dockerfile for the generating the fcrepo-messaging Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/fcrepo-messaging:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.
FROM maven:3.8.6-eclipse-temurin-11 AS dependencies

RUN mkdir -p /var/jars
COPY pom.xml /var/jars
WORKDIR /var/jars

# fetch JARs required for running the Camel routes, but exclude the org.slf4j
# group to avoid a SLF4J conflict with ActiveMQ's own bundled SLF4J library; see
# also http://www.slf4j.org/codes.html#log4jDelegationLoop
RUN mvn dependency:copy-dependencies -DexcludeGroupIds=org.slf4j,ch.qos.logback

FROM openjdk:8u312-jdk-bullseye

ENV ACTIVEMQ_VERSION=5.16.7
ENV ACTIVEMQ_URL=http://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz

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

# remove httpclient 4.5.11 that is bundled with ActiveMQ, because we need to
# make sure we are using 4.5.12+ to properly follow 308 redirects
# use the "-f" flag to avoid failing the build if the file doesn't exist
RUN rm -f $ACTIVEMQ_HOME/lib/optional/httpclient-4.5.11.jar

# remove spring 4.3.30.RELEASE libraries that are bundled with ActiveMQ,
# because we want to use Spring 5
RUN rm -f $ACTIVEMQ_HOME/lib/optional/spring-*-4.3.30.RELEASE.jar

COPY --from=dependencies /var/jars/target/dependency/*.jar $ACTIVEMQ_HOME/lib/optional/

COPY activemq/conf $ACTIVEMQ_HOME/conf/
COPY activemq/env $ACTIVEMQ_HOME/bin/env

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
