FROM centos:8
MAINTAINER lekhrajprasad

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
RUN yum install java-1.8.0-openjdk-devel git wget -y
EXPOSE 2345
ARG maven_version=3.8.1
ENV M2_HOME=/usr/local/apache-maven-${maven_version}
ENV M2="${M2_HOME}/bin"
#Setting path
ENV PATH=$PATH:$M2
WORKDIR /opt/app
RUN wget https://downloads.apache.org/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz -P /tmp \
    && tar xvfz /tmp/apache-maven-${maven_version}-bin.tar.gz -C /usr/local \
    && rm -rf /tmp/apache-maven-${maven_version}-bin.tar.gz \
    && yum clean all
RUN export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
RUN git clone https://github.com/lekhrajprasad/mybookstore-v-1.2.git /tmp/mybookstore
RUN cd /tmp/mybookstore/cloud-config-server \
    && mvn clean package
RUN mv /tmp/mybookstore/cloud-config-server/target/*.jar /opt/app/app.jar

RUN rm -rf /tmp/mybookstore

CMD ["java", "-jar", "/opt/app/app.jar", "--spring.profiles.active=native"]

#To run mannualy command is docker build -t <imagename:version>
#To creaet container : docker run -d -p 2345:2345 --name <containername> <imagename:version>
# Use public ip of ec2 for connection <public-ip>:2345
