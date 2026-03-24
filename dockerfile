# We use Ubuntu 14.04 because it is contemporaneous with Lodash 2.4.1
FROM ubuntu:14.04

# Ubuntu 14.04 is EOL. We must map the sources to old-releases.
RUN sed -i -re 's/([a-z]{2}\.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    wget curl git unzip build-essential python openjdk-7-jre-headless phantomjs \
    && rm -rf /var/lib/apt/lists/*

# Install NVM
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Install ancient Node versions needed for the matrix
RUN . $NVM_DIR/nvm.sh \
    && nvm install 0.6 \
    && nvm install 0.8 \
    && nvm install 0.10 \
    && nvm alias default 0.10

# Install Narwhal
RUN wget https://github.com/280north/narwhal/archive/v0.3.2.zip \
    && unzip v0.3.2.zip -d /opt/ && rm v0.3.2.zip \
    && ln -s /opt/narwhal-0.3.2/bin/narwhal /usr/local/bin/narwhal

# Install Rhino (Replaced dead Sonatype link with stable Maven release)
RUN mkdir /opt/rhino-1.7R5 \
    && wget -O /opt/rhino-1.7R5/js.jar https://repo1.maven.org/maven2/org/mozilla/rhino/1.7R5/rhino-1.7R5.jar \
    && echo '#!/bin/sh\njava -jar /opt/rhino-1.7R5/js.jar $@' > /usr/local/bin/rhino \
    && chmod +x /usr/local/bin/rhino

# Install RingoJS
RUN wget https://github.com/ringojs/ringojs/releases/download/v0.9/ringojs-0.9.zip \
    && unzip ringojs-0.9.zip -d /opt && rm ringojs-0.9.zip \
    && ln -s /opt/ringojs-0.9/bin/ringo /usr/local/bin/ringo

WORKDIR /lodash
COPY . .

# Critical: Turn off strict SSL so old NPM (HTTP) won't fail due to expired registry certs
RUN . $NVM_DIR/nvm.sh && npm config set strict-ssl false -g

CMD ["bash"]