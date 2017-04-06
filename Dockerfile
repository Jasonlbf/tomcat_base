FROM ubuntu:xenial
MAINTAINER J 

# ENV DEBIAN_FRONTEND noninteractive

# change timezone
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# ADD sources.list /etc/apt/sources.list


#ENV VERSION 8
#ENV UPDATE 121
#ENV BUILD 13
#
#ENV JAVA_HOME /srv/jdk1.${VERSION}.0_${UPDATE}
#ENV JRE_HOME ${JAVA_HOME}/jre
#
#ADD jdk-8u121-linux-x64.tar.gz /srv
#
#RUN  apt-get update && \
#     apt-get install -y \
#     curl \
#     gcc \
#     libapr1 \
#     libapr1-dev \
#     libreadline-dev \
#     make  && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \ 
  curl \
  ca-certificates \
  wget \
  gcc \
  libapr1 \
  make \
  libreadline-dev \
  software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JRE_HOME ${JAVA_HOME}/jre


# Tomcat
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.13
ENV TOMCAT_TGZ_URL http://mirrors.aliyuncs.com/apache/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

RUN \
    curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz && \
    tar -xzvf tomcat.tar.gz --strip-components=1 && \
    rm bin/*.bat && \
    rm tomcat.tar.gz*

RUN apt-get install -y libtcnative-1 && \
  cp /usr/lib/x86_64-linux-gnu/libtcnative-1.so /opt/tomcat/lib/ && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Apache native libraries (apr)
#ENV TOMCAT_NATIVE_LIBDIR $CATALINA_HOME/native-jni-lib
#ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR
#ENV APACHE_NATIVE_VERSION 1.2.12
#ENV APACHE_NATIVE_URL http://mirrors.aliyuncs.com/apache/tomcat/tomcat-connectors/native/$APACHE_NATIVE_VERSION/source/tomcat-native-$APACHE_NATIVE_VERSION-src.tar.gz
#RUN \
#    curl -fSL "$APACHE_NATIVE_URL" -o native.tar.gz && \
#    tar zxf native.tar.gz -C /tmp && \
#    cd /tmp/tomcat-native*-src/native/ && \
#    ./configure \
#        --prefix=/opt/tomcat \
#        --with-apr=/usr/bin/apr-1-config \
#        --with-java-home=/usr/lib/jvm/java-8-oracle \
#        --with-ssl=no && \
#    make && \
#    make install && \
#    apt-get purge -y \
#        libapr1-dev


RUN \
    groupadd -r tomcat -g 1000 && \
    useradd -u 1000 -r -g tomcat -d $CATALINA_HOME -s /bin/bash tomcat

# Tomcat user helpers
COPY files/.bash_profile $CATALINA_HOME/.bash_profile
COPY files/.bash_logout $CATALINA_HOME/.bash_logout

# Tomcat config
COPY files/setenv.sh $CATALINA_HOME/bin/setenv.sh
COPY files/javaopts.sh $CATALINA_HOME/bin/javaopts.sh
COPY files/server.xml $CATALINA_HOME/conf/server.xml
# COPY files/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml

# Create a self-signed certificate for Tomcat to use
#RUN \
#    openssl req \
#        -new \
#        -newkey rsa:4096 \
#        -days 3650 \
#        -nodes \
#        -x509 \
#        -subj "/C=US/ST=Alaska/L=Anchorage/O=Axiom Data Science/CN=tomcat.example.com" \
#        -keyout $CATALINA_HOME/conf/ssl.key \
#        -out $CATALINA_HOME/conf/ssl.crt

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" && \
    export GNUPGHOME="$(mktemp -d)" && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

RUN chown -R tomcat:tomcat "$CATALINA_HOME"

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080 8443
CMD ["catalina.sh", "run"]
