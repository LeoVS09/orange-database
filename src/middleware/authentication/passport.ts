import passport from "koa-passport"
import route from "koa-route"
import Koa from 'koa'
import postgres from "pg"

import config from '../../../config.json'

const {allowedOrigins} = config;

// TODO: use passport-github2
import {Strategy as GitHubStrategy} from "passport-github"


/*
 * This file uses regular Passport.js authentication, both for
 * username/password and for login with GitHub. You can easily add more OAuth
 * providers to this file. For more information, see:
 *
 *   http://www.passportjs.org/
 */

export default function (app: Koa, {rootPgPool}: { rootPgPool: postgres.Pool }) {
   app.use(async (ctx, next) => {

      let origin = ctx.req.headers.origin || 'null';

      if (Array.isArray(origin)) {
         origin = origin[0]
      }

      if (allowedOrigins.indexOf(origin) !== -1) {
         ctx.set("Access-Control-Allow-Origin", origin);
         ctx.set("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
         ctx.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
         ctx.set('Access-Control-Allow-Credentials', 'true');
      }

      await next()
   });

   passport.serializeUser((user, done) => {
      // @ts-ignore
      done(null, user.id);
   });

   passport.deserializeUser(async (id, callback) => {
      let error = null;
      let user;
      console.log("deserializeUser", id)
      try {
         const {
            rows: [_user],
         } = await rootPgPool.query(
               `select users.*
                from app_public.users
                where users.id = $1`,
            [id]
         );
         user = _user || false;
      } catch (e) {
         error = e;
      } finally {
         callback(error, user);
      }
   });
   app.use(passport.initialize());
   app.use(passport.session());

   if (process.env.GITHUB_KEY && process.env.GITHUB_SECRET) {
      passport.use(
         new GitHubStrategy(
            {
               clientID: process.env.GITHUB_KEY,
               clientSecret: process.env.GITHUB_SECRET,
               callbackURL: `${process.env.ROOT_URL}/auth/github/callback`,
            },
            async function (accessToken, refreshToken, profile, done) {
               let error;
               let user;
               try {
                  const {rows} = await rootPgPool.query(
                        `select *
                         from app_private.link_or_register_user($1, $2, $3, $4, $5) users
                         where not (users is null);`,
                     [
                        null,
                        "github",
                        profile.id,
                        JSON.stringify({
                           username: profile.username,
                           // @ts-ignore
                           avatar_url: profile._json.avatar_url,
                           name: profile.displayName,
                        }),
                        JSON.stringify({
                           accessToken,
                           refreshToken,
                        }),
                     ]
                  );
                  user = rows[0] || false;
               } catch (e) {
                  error = e;
               } finally {
                  done(error, user);
               }
            }
         )
      );

      app.use(route.get("/auth/github", passport.authenticate("github")));

      app.use(
         route.get(
            "/auth/github/callback",
            passport.authenticate("github", {
               successRedirect: "/",
               failureRedirect: "/login",
            })
         )
      );
   } else {
      console.error(
         "WARNING: you've not set up the GitHub application for login; see `.env` for details"
      );
   }
   app.use(
      route.get("/logout", async ctx => {
         ctx.logout();
         ctx.redirect("/");
      })
   );
};
