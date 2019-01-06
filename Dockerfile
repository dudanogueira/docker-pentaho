FROM openjdk:8-jre-slim

MAINTAINER Duda Nogueira dudanogueira@gmail.com

# Init ENV
ENV PENTAHO_HOME /opt/pentaho

# Apply JAVA_HOME
RUN . /etc/environment
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV PENTAHO_JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64

# Install Dependences
RUN apt-get update; apt-get install zip netcat -y; \
    apt-get install wget unzip git vim -y; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir ${PENTAHO_HOME}; useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; chown pentaho:pentaho ${PENTAHO_HOME}

#COPY accessibility.properties /etc/java-8-openjdk/


# VERSION 8.2
# https://downloads.sourceforge.net/project/pentaho/Pentaho%208.2/server/pentaho-server-ce-8.2.0.0-342.zip
#
# VERSION 8.1
# https://downloads.sourceforge.net/project/pentaho/Pentaho%208.1/server/pentaho-server-ce-8.1.0.0-365.zip


USER pentaho


ENV PENTAHO_URL  https://downloads.sourceforge.net/project/pentaho/Pentaho%208.1/server/pentaho-server-ce-8.1.0.0-365.zip
ENV PENTAHO_FILE pentaho-server-ce-8.1.0.0-365.zip
# try to get from local first

#COPY ./$PENTAHO_FILE /tmp/$PENTAHO_FILE

RUN wget --progress=dot:giga -c $PENTAHO_URL -O /tmp/$PENTAHO_FILE

RUN /usr/bin/unzip -q /tmp/$PENTAHO_FILE -d  $PENTAHO_HOME; \
    rm -f /tmp/$PENTAHO_FILE $PENTAHO_HOME/pentaho-server/promptuser.sh; \
    sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/pentaho-server/tomcat/bin/startup.sh; \
    chmod +x $PENTAHO_HOME/pentaho-server/start-pentaho.sh

USER root

# UPDATE DRIVERS
# Get MS SQL JDBC driver
ADD https://download.microsoft.com/download/0/2/A/02AAE597-3865-456C-AE7F-613F99F850A8/enu/sqljdbc_6.0.8112.100_enu.tar.gz tmp.tar.gz
RUN tar -zxf tmp.tar.gz && \
	rm -f tmp.tar.gz && \
	cp sqljdbc_6.0/enu/jre8/sqljdbc42.jar ${PENTAHO_HOME}/pentaho-server/tomcat/lib/ && \
	rm -fr sqljdbc_6.0

# Replace outdated Postgresql JDBC driver
# RUN rm ${PENTAHO_HOME}/pentaho-server/tomcat/lib/postgresql-9.3-1102-jdbc4.jar && \
#     echo https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar | xargs wget -qO- -O ${PENTAHO_HOME}/pentaho-server/omcat/lib/postgresql-9.4.1212.jar



# PIVOT 4 J
RUN wget https://ci.greencatsoft.com/job/Pivot4J/439/artifact/pivot4j-pentaho/target/pivot4j-pentaho-1.0-SNAPSHOT-plugin.zip -O /tmp/pivot4j.zip
RUN /usr/bin/unzip -q /tmp/pivot4j.zip -d $PENTAHO_HOME/pentaho-server/pentaho-solutions/system/ && \
    rm -f /tmp/pivot4j.zip

# SAIKU - http://meteorite.bi
# http://meteorite.bi/downloads/saiku-plugin-p7.1-3.90.zip
# GET THE FREE LICENSE at http://meteorite.bi
# the host of the license must match the container host
RUN wget http://meteorite.bi/downloads/saikuee-plugin-p7-3.17.zip -O /tmp/saiku.zip
RUN /usr/bin/unzip -q /tmp/saiku.zip -d $PENTAHO_HOME/pentaho-server/pentaho-solutions/system/ && \
    rm -f /tmp/saiku.zip


EXPOSE 8080 

# PRE CONFIG THE DESIRED OPTIONS


# this will remove the login hint feature
# $PENTAHO_HOME pentaho-server/pentaho-solutions/system/pentaho.xml 
# <login-show-sample-users-hint>false</login-show-sample-users-hint>

# reference: https://help.pentaho.com/Documentation/8.1/Setup/Administration/User_Security/Pass_Authentication_Credentials_in_URL_Parameters
# $PENTAHO_HOME pentaho-server/pentaho-solutions/system/security.properties
# requestParameterAuthenticationEnabled=true



CMD ["sh", "/opt/pentaho/pentaho-server/start-pentaho.sh"]

#
# PLUGINS
# Ivy (D)ashboard (C)omponents
# http://downloads.sourceforge.net/project/ivylabs/Pentaho/BI%20Server/Ivy%20IS%20Dashboard%20Components/0.0.6/IvyDC.zip
# Ivy (B)ootstrap (C)omponents
# http://downloads.sourceforge.net/project/ivylabs/Pentaho/BI%20Server/Ivy%20IS%20Bootstrap%20Components%20%28free%20version%29/1.0.4%20%28free%20version%29/IvyBC.zip
# TAPA
# https://github.com/marpontes/tapa/archive/v0.3.2.zip
# IVGS
# http://downloads.sourceforge.net/project/ivylabs/Pentaho/BI%20Server/Ivy%20IS%20Git%20Sync/2.0.0/IvyGS.zip
# Integrator
# https://github.com/kleysonr/pentaho-integrator-plugin/releases/download/v0.1.0/integrator-0.1.0.zip
# B TABLE
# https://heanet.dl.sourceforge.net/project/btable/Version3.0-3.6/BTable-pentaho7-3.6-STABLE.zip
# https://ci.greencatsoft.com/job/Pivot4J/439/artifact/pivot4j-pentaho/target/pivot4j-pentaho-1.0-SNAPSHOT-plugin.zip

