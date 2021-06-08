FROM centos:8 as mybuild
MAINTAINER lekhraj.prasad@gmail.com
RUN yum install java-11-openjdk-devel git wget -y

ARG maven_version=3.8.1
ENV M2_HOME=/usr/local/apache-maven-${maven_version}
ENV M2="${M2_HOME}/bin"
ENV PATH=$PATH:$M2
WORKDIR /opt/app
RUN wget https://downloads.apache.org/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz -P /tmp \
    && tar xvfz /tmp/apache-maven-${maven_version}-bin.tar.gz -C /usr/local \
    && rm -rf /tmp/apache-maven-${maven_version}-bin.tar.gz \
    && yum clean all
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.11.0.9-2.el8_4.x86_64

RUN git clone https://github.com/lekhrajprasad/my-cloud-config-server.git /tmp/myapp \
    && cd /tmp/myapp \
    && mvn clean package \
    && mv /tmp/myapp/target/*.jar /opt/app/app.jar

RUN rm -rf /tmp/*

FROM adoptopenjdk/openjdk11:jre-11.0.6_10-alpine
EXPOSE 8888

WORKDIR /opt
COPY --from=mybuild /opt/app/app.jar /opt/app.jar
VOLUME ["./logs"]
ENTRYPOINT ["java", "-jar", "/opt/app.jar"]

#To run mannualy command is docker build -t <imagename:version>
#To creaet container : docker run -d -p 2345:2345 --name <containername> <imagename:version>
# Use public ip of ec2 for connection <public-ip>:2345
