FROM danieldent/meteor:onbuild

EXPOSE 80
ENV PORT 80
CMD ["/bin/bash", "-c", "MONGO_URL=$MONGODB_URL /usr/local/bin/node main.js"]
