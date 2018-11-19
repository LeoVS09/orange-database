import http from 'http'
import Koa from 'koa'
import postgres from 'pg'
import * as utils from './utils'
import installMiddlewares from './middleware'

utils.sanitiseEnv();

const PORT = parseInt(process.env.PORT  || "3000", 10);
const isDev = process.env.NODE_ENV === "development";

const rootPgPool = new postgres.Pool({
  connectionString: process.env.ROOT_DATABASE_URL,
});

// We're using a non-super-user connection string, so we need to install the
// watch fixtures ourself.
if (isDev) {
  utils.installWatchFixtures(rootPgPool);
}

const app = new Koa();

installMiddlewares(app, {rootPgPool});

const server = http.createServer(app.callback());

server.listen(PORT);
console.log(`Listening on port ${PORT}`);
