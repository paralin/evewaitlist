FROM node:4.6-wheezy
RUN apt-get update && apt-get install build-essential -y && apt-get clean

ADD . /build/
RUN curl https://install.meteor.com/ | sh && \
    cd /build && meteor build --directory /bundle/ && \
    rm -rf /build && mkdir /app/ && mv /bundle/bundle/* /app/ && rm -rf /bundle/ && \
    cd /app/programs/server/ && npm install && rm -rf /root/.meteor/ && \
    rm -rf /root/.meteor

WORKDIR /app/

ENV PORT=80
CMD node main.js
EXPOSE 80
