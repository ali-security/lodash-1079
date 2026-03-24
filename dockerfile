# Start from the official ancient Node.10 image. 
# This bypasses the need to use apt-get on broken ubuntu old-releases.
FROM --platform=linux/amd64 node:0.10

# Set baseline environment variables
ENV BIN="node"
ENV BUILD=false
ENV COMPAT=false
ENV MAKE=false
ENV OPTION=""
ENV SAUCE_LABS=false

# Install NVM to manage the 0.6, 0.8, and 0.10 matrix
# (node:0.10 has curl and git pre-installed)
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Install the other ancient Node versions needed for the matrix
RUN . $NVM_DIR/nvm.sh \
    && nvm install 0.6 \
    && nvm install 0.8 \
    && nvm install 0.10 \
    && nvm alias default 0.10

# Install Narwhal
RUN wget https://github.com/280north/narwhal/archive/v0.3.2.zip \
    && unzip v0.3.2.zip -d /opt/ && rm v0.3.2.zip \
    && ln -s /opt/narwhal-0.3.2/bin/narwhal /usr/local/bin/narwhal

# Install Rhino (node:0.10 doesn't have Java, but we can grab an older JRE binary if needed, 
# or just pull the jar file down for now)
RUN mkdir /opt/rhino-1.7R5 \
    && wget -O /opt/rhino-1.7R5/js.jar https://repo1.maven.org/maven2/org/mozilla/rhino/1.7R5/rhino-1.7R5.jar \
    && echo '#!/bin/sh\njava -jar /opt/rhino-1.7R5/js.jar $@' > /usr/local/bin/rhino \
    && chmod +x /usr/local/bin/rhino

# Install RingoJS
RUN wget https://github.com/ringojs/ringojs/releases/download/v0.9/ringojs-0.9.zip \
    && unzip ringojs-0.9.zip -d /opt && rm ringojs-0.9.zip \
    && ln -s /opt/ringojs-0.9/bin/ringo /usr/local/bin/ringo

# Install PhantomJS manually (using a statically linked binary to avoid library dependencies)
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 \
    && tar -xjf phantomjs-1.9.8-linux-x86_64.tar.bz2 \
    && mv phantomjs-1.9.8-linux-x86_64 /usr/local/share/phantomjs \
    && ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs \
    && rm phantomjs-1.9.8-linux-x86_64.tar.bz2

WORKDIR /app
COPY . .

# Turn off strict SSL so ancient NPM won't fail due to expired registry certs
RUN npm config set strict-ssl false -g

# Note: For testing locally, you drop into the bash shell
CMD ["bash"]