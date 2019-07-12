# Docker file for a CentOS-based Python3 image

FROM centos/s2i-base-centos7
MAINTAINER fnndsc "dev@babymri.org"

ENV PYTHON_VERSION=3.6 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PIP_NO_CACHE_DIR=off

ENV SUMMARY="Platform for building and running Python $PYTHON_VERSION applications" \
    DESCRIPTION="Python $PYTHON_VERSION available as docker container is a base platform for \
building and running various Python $PYTHON_VERSION applications and frameworks. \
Python is an easy to learn, powerful programming language. It has efficient high-level \
data structures and a simple but effective approach to object-oriented programming. \
Python's elegant syntax and dynamic typing, together with its interpreted nature, \
make it an ideal language for scripting and rapid application development in many areas \
on most platforms."

RUN yum install -y centos-release-scl-rh && \
    yum-config-manager --enable centos-sclo-rh-testing && \
    INSTALL_PKGS="rh-python36 rh-python36-python-pip" &&\
    yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# - Create a Python virtual environment for use by any application to avoid
#   potential conflicts with Python packages preinstalled in the main Python
#   installation.
# - In order to drop the root user, we have to make some directories world
#   writable as OpenShift default security model is to run the container
#   under random UID.

RUN source scl_source enable rh-python36 && \
    virtualenv /opt/app-root && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root && \
    rpm-file-permissions && \
    pip3.6 install pfurl --user

ENV HOME /var/jenkins_home
ENV JENKINS_HOME /var/jenkins_home

RUN wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo && \
  rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key && \
  yum install -y zip unzip java-1.7.0-openjdk docker jenkins && yum clean all 


RUN  usermod -m -d "$JENKINS_HOME" jenkins && \
  chown -R jenkins "$JENKINS_HOME"

# install basic tools
RUN yum install --quiet git subversion vim wget curl tar -y && yum clean all -y

# add java opts to .bashrc file
RUN echo "export JAVA_OPTIONS=${JAVA_OPTIONS}" >> ${JENKINS_HOME}/.bashrc

# create custom run.sh
RUN wget --quiet http://mirrors.jenkins-ci.org/war/latest/jenkins.war -O /opt/jenkins.war && chown ${appname}:${appname} /opt/jenkins.war

# create custom run.sh
RUN echo "/opt/jdk18/bin/java ${JAVA_OPTS} -jar /opt/jenkins.war ${JENKINS_OPTIONS}" >> /opt/run.sh



# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

# start jenkins on container start
CMD su - jenkins -c "sh /opt/run.sh"
