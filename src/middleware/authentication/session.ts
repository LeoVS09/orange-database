import session from "koa-session"
import Koa from 'koa'
import jwt from 'jsonwebtoken'

const JWT_SECRET = process.env.JWT_SECRET as string
if(!JWT_SECRET)
   throw new Error('Not have jwt secret')

const SESSION_SECRET = process.env.SECRET as string
if(!SESSION_SECRET)
   throw new Error('Not have session secret')

const maxAge = 86400000 * 2 // 2 days in ms

export default function (app: Koa) {

  app.keys = [SESSION_SECRET];

  app.use(session({
      renew: true,
     maxAge,

     encode: obj => {
         return jwt.sign({session: obj}, JWT_SECRET, {
            expiresIn: maxAge,
            notBefore: "10ms" // token valid after 10 ms
         })
     },

     decode: token => {
         return jwt.verify(token, JWT_SECRET).session
     }
  }, app));
};
