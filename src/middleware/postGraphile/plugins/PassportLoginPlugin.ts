import {makeExtendSchemaPlugin, gql} from "graphile-utils"
import postgres from 'pg'
import {PgContext} from "../index";

interface PgPluginContext extends PgContext{
   pgClient: any
}

export default makeExtendSchemaPlugin(build => ({
   typeDefs: gql`
      input RegisterInput {
         username: String!
         email: String!
         password: String!
         name: String
         avatarUrl: String
         firstName: String!
         middleName: String
         lastName: String
      }

      type RegisterPayload {
         user: User! @pgField
      }

      input LoginInput {
         username: String!
         password: String!
      }

      type LoginPayload {
         user: User! @pgField
      }

      extend type Mutation {
         register(input: RegisterInput!): RegisterPayload
         login(input: LoginInput!): LoginPayload
      }
   `,
   resolvers: {
      Mutation: {
         async register(
            mutation,
            args,
            context,
            resolveInfo,
            {selectGraphQLResultFromTable}
         ) {
            const {username, password, email, name, avatarUrl, firstName, middleName, lastName} = args.input;
            const {rootPgPool, login, pgClient} = context as PgPluginContext;
            try {

               const {
                  rows: [user],
               } = await rootPgPool.query(
                     `select users.*
                        from app_private.really_create_user(
                           username => $1,
                           email => $2,
                           email_is_verified => false,
                           name => $3,
                           avatar_url => $4,
                           password => $5
                        ) users where not (users is null)
                      `,
                  [username, email, name, avatarUrl, password]
               );

               console.log('Register user result', user)

               if (!user)
                  throw new Error("Unexpected error when register, user not created");

               try {
                  // TODO: move profile and user registration in postgres
                  const {rows: [profile]} = await rootPgPool.query(
                     `insert into app_public.profiles(
                       user_id,
                       first_name,
                       middle_name,
                       last_name)
                     VALUES ($1, $2, $3, $4) returning *`,
                     [user.id, firstName, middleName || '', lastName]
                  )

                  console.log('Profile registration result', profile)
               }catch (e) {
                  console.error('Error when register profile:', e)
                  console.log('Trying delete user without profile')

                  await rootPgPool.query(
                    `delete from app_public.users
                        where id == $1
                     `,
                     [user.id]
                  );

                  throw e
               }

               const [row] = await loginPassportAndPg(user, login, pgClient, build, selectGraphQLResultFromTable)

               return {
                  data: row,
               };
            } catch (e) {
               console.error('Error when register:', e);
               // TODO: check that this is indeed why it failed
               throw new Error("Registration failed: incorrect username/password");
            }
         },
         async login(
            mutation,
            args,
            context,
            resolveInfo,
            {selectGraphQLResultFromTable}
         ) {
            const {username, password} = args.input;
            const {rootPgPool, login, pgClient} = context;
            console.log("passport-plugin")
            try {
               // Call our login function to find out if the username/password combination exists
               const {
                  rows: [user],
               } = await rootPgPool.query(
                     `select users.* from app_private.login($1, $2) 
                        users where not (users is null)
                      `,
                  [username, password]
               );

               console.log("try login user", user)

               if (!user)
                  throw new Error("Login failed");

               const [row] = await loginPassportAndPg(user, login, pgClient, build, selectGraphQLResultFromTable)
               console.log('row', row)
               return {
                  data: row,
               };
            } catch (e) {
               console.error("Error when login", e);
               // TODO: check that this is indeed why it failed
               throw new Error("Login failed: incorrect username/password");
            }
         },
      },
   },
}));

// TODO: more types support
async function loginPassportAndPg(user: any, login: any, pgClient: any, build: any, selectGraphQLResultFromTable: any) {
   // Tell Passport.js we're logged in
   await login(user);
   // Tell pg we're logged in
   await pgClient.query("select set_config($1, $2, true);", [
      "jwt.claims.user_id",
      user.id,
   ]);

   // Fetch the data that was requested from GraphQL, and return it
   const sql = build.pgSql;
   return await selectGraphQLResultFromTable(
      sql.fragment`app_public.users`,
      (tableAlias: any, sqlBuilder: any) => {
         sqlBuilder.where(
            sql.fragment`${tableAlias}.id = ${sql.value(user.id)}`
         );
      }
   );
}
