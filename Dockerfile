FROM danieldent/meteor:latest
MAINTAINER Christian Stewart
COPY . /opt/src
WORKDIR /opt/src
RUN meteor build .. --debug --directory \
    && cd ../bundle/programs/server \
    && npm install \
    && rm -rf /opt/src
WORKDIR /opt/bundle
USER nobody

EXPOSE 8080
ENV PORT 8080
CMD ["/bin/bash", "-c", "MONGO_URL=$MONGODB_URL /usr/local/bin/node main.js"]
