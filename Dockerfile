FROM bitnami/git:2.41.0 as git

WORKDIR /app

RUN git clone https://github.com/ddung1203/youtube-reloaded.git .
RUN rm -rf README.md

FROM node:18.16-buster-slim

WORKDIR /app

COPY --from=git /app .
RUN npm install
RUN npm run build

EXPOSE 4000
CMD ["npm", "start"]
