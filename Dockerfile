FROM node:11.2-alpine

WORKDIR /app

COPY . /app

RUN apk add --update --no-cache bash bash-completion make git

RUN npm i -g yarn

RUN yarn install

ENTRYPOINT ["/bin/bash", "docker-entrypoint.sh"]

CMD ["make start"]

EXPOSE 8765
