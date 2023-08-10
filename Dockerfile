FROM node:18.16-buster-slim

WORKDIR /app

COPY . .
RUN npm install
RUN npm run build

EXPOSE 4000
CMD ["npm", "start"]