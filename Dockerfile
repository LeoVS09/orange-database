FROM node:11.14-stretch as base

RUN apt update && apt upgrade -y && \
   apt install -y bash bash-completion make curl wget

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
   echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch"-pgdg main | tee  /etc/apt/sources.list.d/pgdg.list && \
   apt update && \
   apt -y install postgresql-11

RUN npm i -g npx

WORKDIR /ws

COPY package.json yarn.lock /ws/
RUN yarn

FROM base

COPY . /ws

RUN yarn build

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["./bin/start.sh"]

EXPOSE 8765
