import Koa from 'koa'

import installPostGraphile from './postGraphile'
import installPassport from './authentication/passport'
import installSession from './authentication/session'
import installStandardKoaMiddleware from './standartKoa'
import postgres from "pg";

export default function (app: Koa, { rootPgPool }: {rootPgPool: postgres.Pool }) {
	installStandardKoaMiddleware(app);
	installSession(app);
	installPassport(app, { rootPgPool });
	installPostGraphile(app, { rootPgPool });
}

export {
	installStandardKoaMiddleware,
  installPostGraphile,
  installPassport,
  installSession
}
