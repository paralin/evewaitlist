FROM danieldent/meteor:onbuild

CMD ["/bin/bash", "-c", "MONGO_URL=$MONGODB_URL /usr/local/bin/node main.js"]
