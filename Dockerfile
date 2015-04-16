FROM debian:jessie
MAINTAINER Arve Knudsen <arve.knudsen@gmail.com>

RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | \
tee /etc/apt/sources.list.d/webupd8team-java.list && \
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | \
tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-get update

# Install Java
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | \
debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 \
seen true | debconf-set-selections && DEBIAN_FRONTEND=noninteractive \
apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default

# Install sbt
RUN apt-get install -y --force-yes unzip sbt

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install activator
WORKDIR /opt
RUN wget http://downloads.typesafe.com/typesafe-activator/1.3.2/typesafe-activator-1.3.2.zip
RUN unzip typesafe-activator-1.3.2.zip
RUN rm typesafe-activator-1.3.2.zip
ENV PATH /opt/activator-1.3.2:$PATH

# Install Node
ENV NODE_VERSION 0.12.2
ENV NPM_VERSION 2.7.3
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D
RUN wget "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
&& wget "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
&& gpg --verify SHASUMS256.txt.asc \
&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
&& rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
&& npm install -g npm@"$NPM_VERSION"
RUN npm cache clear

EXPOSE 9000

ENTRYPOINT ["sbt"]
