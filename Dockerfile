FROM danieldent/meteor:latest
MAINTAINER Christian Stewart

WORKDIR /opt/bundle
ADD .meteor/ /opt/bundle/.meteor/
ADD bower.json /opt/bundle/bower.json

COPY . /opt/bundle
USER root

EXPOSE 8080
ENV PORT 8080
CMD ["/bin/bash", "-c", "MONGO_URL=$MONGODB_URL meteor --port 8080"]
