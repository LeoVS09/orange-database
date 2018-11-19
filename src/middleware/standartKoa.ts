import Koa from 'koa'
import helmet from "koa-helmet"
import cors from "@koa/cors"
import compose from 'koa-compose'
// import jwt from "koa-jwt"
import compress from "koa-compress"
import bunyanLogger from "koa-bunyan-logger"
import bodyParser from "koa-bodyparser"

export default (app: Koa) =>
  // These middlewares aren't required, I'm using them to check PostGraphile
  // works with Koa.

  compose([
    helmet(),
    cors(),
    //jwt({secret: process.env.SECRET}),
    compress(),
    bunyanLogger(),
    bodyParser()
  ]);
