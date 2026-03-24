# Start from the official ancient Node.10 image. 
FROM node:0.10

# Globally force curl and wget to ignore SSL errors for all subsequent commands (like nvm)
RUN echo "insecure" > ~/.curlrc && echo "check-certificate = off" > ~/.wgetrc

# Set baseline environment variables
ENV BIN="node"
ENV BUILD=false
ENV COMPAT=false
ENV MAKE=false
ENV OPTION=""
ENV SAUCE_LABS=false

# Install NVM
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Install Node 0.8 and 0.10
RUN . $NVM_DIR/nvm.sh \
    && nvm install 0.8 \
    && nvm install 0.10 \
    && nvm alias default 0.10

# Install Narwhal (switched to .tar.gz to avoid needing 'unzip')
RUN wget https://github.com/280north/narwhal/archive/refs/tags/v0.3.2.tar.gz \
    && tar -xzf v0.3.2.tar.gz -C /opt/ && rm v0.3.2.tar.gz \
    && ln -s /opt/narwhal-0.3.2/bin/narwhal /usr/local/bin/narwhal

# Install Rhino 
RUN mkdir /opt/rhino-1.7R5 \
    && wget -O /opt/rhino-1.7R5/js.jar https://repo1.maven.org/maven2/org/mozilla/rhino/1.7R5/rhino-1.7R5.jar \
    && echo '#!/bin/sh\njava -jar /opt/rhino-1.7R5/js.jar $@' > /usr/local/bin/rhino \
    && chmod +x /usr/local/bin/rhino

# Install RingoJS (switched to .tar.gz to avoid needing 'unzip')
RUN wget https://github.com/ringojs/ringojs/releases/download/v0.9/ringojs-0.9.tar.gz \
    && tar -xzf ringojs-0.9.tar.gz -C /opt/ && rm ringojs-0.9.tar.gz \
    && ln -s /opt/ringojs-0.9/bin/ringo /usr/local/bin/ringo

# Install PhantomJS manually (using a mirror that provides .tar.gz so we don't need bzip2)
RUN wget https://github.com/Medium/phantomjs/releases/download/v1.9.19/phantomjs-1.9.8-linux-x86_64.tar.bz2 -O phantomjs.tar.bz2 \
    && tar -xjf phantomjs.tar.bz2 \
    && mv phantomjs-1.9.8-linux-x86_64 /usr/local/share/phantomjs \
    && ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs \
    && rm phantomjs.tar.bz2

WORKDIR /app
COPY . .

# Turn off strict SSL so ancient NPM won't fail due to expired registry certs
RUN npm config set strict-ssl false -g

CMD ["bash"]