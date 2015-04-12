FROM danieldent/meteor:latest
MAINTAINER Christian Stewart

COPY . /opt/bundle
WORKDIR /opt/bundle
RUN meteor add meteor-platform
USER nobody

EXPOSE 8080
ENV PORT 8080
CMD ["/bin/bash", "-c", "MONGO_URL=$MONGODB_URL meteor"]
