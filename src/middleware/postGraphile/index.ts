import postgraphile from 'postgraphile'
import postgres from 'pg'
import Koa from 'koa'
import {PassportLoginPlugin} from "./plugins"

import { connection, schema, options } from './configuration'

const visitor_role = "orange_visitor"

export default function (app: Koa, { rootPgPool }: {rootPgPool: postgres.Pool}) {
   app.use((ctx, next) => {
      // PostGraphile deals with (req, res) but we want access to sessions from `pgSettings`, so we make the ctx available on req.
      // @ts-ignore
      ctx.req.ctx = ctx;
      return next();
   });

   app.use(
      postgraphile(connection, schema, {
         // Import our shared options
         ...options,

         // Since we're using sessions we'll also want our login plugin
         appendPlugins: [
            // All the plugins in our shared config
            ...(options.appendPlugins || []),

            // Adds the `login` mutation to enable users to log in
            PassportLoginPlugin,
         ],

         // Given a request object, returns the settings to set within the
         // Postgres transaction used by GraphQL.
         async pgSettings(req) {
            const authHeader = req.headers.authorization;
            if (!authHeader)
               console.error("No authorization header provided")

            // @ts-ignore
            const ctx: Koa.Context = req.ctx;

            console.log('pgSettings', ctx.state.user)
            return {
               role: visitor_role,
               "jwt.claims.user_id": ctx.state.user && ctx.state.user.id,
            };
         },

         // The return value of this is added to `context` - the third argument of
         // GraphQL resolvers. This is useful for our custom plugins.
         async additionalGraphQLContextFromRequest(req): Promise<PgContext> {
            // @ts-ignore
            const ctx: Koa.Context = req.ctx;

            return {
               // Let plugins call priviliged methods (e.g. login) if they need to
               rootPgPool,

               // Use this to tell Passport.js we're logged in
               async login(user: any) {
                  return await ctx.login(user);
               },
            };
         },
      })
   );
};

export interface PgContext {
   rootPgPool: postgres.Pool
   login: (user: any) => Promise<void>
}
