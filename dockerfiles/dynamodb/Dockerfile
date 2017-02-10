FROM anapsix/alpine-java:8
MAINTAINER 'Jussi Heinonen<heinonen.jussi@gmail.com>'

ADD sh/service/run_dynamodb.sh /

#Openjdk8 package name openjdk8-jre
RUN apk add -U py-pip && pip install --upgrade pip && \
    apk add openssh build-base python-dev py-boto git libffi-dev openssl-dev bash curl && \
    pip install --upgrade awscli requests && \
    mkdir -p /opt/dynamodb && cd /opt/dynamodb && \
    curl -s https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz | tar -xzv

# Clean
RUN rm -rf /var/cache/apk/*

CMD /bin/bash /run_dynamodb.sh && /bin/bash
