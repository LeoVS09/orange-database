import session from "koa-session"
import Koa from 'koa'

export default function (app: Koa) {
	// @ts-ignore
  app.keys = [process.env.SECRET];
  app.use(session({}, app));
};
