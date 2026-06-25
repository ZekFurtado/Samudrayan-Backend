FROM node:20

RUN mkdir -p /srv/samudrayan_backend

COPY . /srv/samudrayan_backend

WORKDIR /srv/samudrayan_backend

RUN npm install

CMD ["node", "server.js"]