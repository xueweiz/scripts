FROM ubuntu:18.04

# Install base applications
RUN apt-get update
RUN apt-get install -y python python3 curl

# Install Google Cloud SDK
RUN curl https://sdk.cloud.google.com | bash

COPY script.sh /tmp/script.sh
RUN chmod 777 /tmp/script.sh

CMD ["/tmp/script.sh"]
