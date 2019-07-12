#REFERENCE Image
#jenkinsci/slave:latest

FROM fnndsc/centos-python3

##########################################
##    prepare jenkins slave run env     ##
##########################################
ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins
RUN mkdir /home/jenkins/.tmp
VOLUME ["/home/jenkins"]


ENV PYCURL_SSL_LIBRARY=nss

##########################################
##        prepare java run env          ##
##########################################
#RUN yum update -y
RUN yum install -y wget && yum clean packages
RUN yum install -y java-1.8.0-openjdk
RUN echo $PYCURL_SSL_LIBRARY
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --compile pycurl
RUN pip install pfurl


ENV JAVA_HOME /usr/java/jdk1.8.0_101
ENV PATH $PATH:$JAVA_HOME/bin

WORKDIR $HOME
USER root
