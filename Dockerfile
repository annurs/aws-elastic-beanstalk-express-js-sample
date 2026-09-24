FROM node:16

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

EXPOSE 8080

USER node

CMD ["npm", "start"]
