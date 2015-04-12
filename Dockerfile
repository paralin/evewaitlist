FROM danieldent/meteor:onbuild

EXPOSE 8080
ENV PORT 8080
CMD ["/bin/bash", "-c", "MONGO_URL=$MONGODB_URL /usr/local/bin/node main.js"]
