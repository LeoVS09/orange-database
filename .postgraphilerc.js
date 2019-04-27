/**
 * This configuration file don't used in production
 * In current project used koa as server with PostGraphile middleware
 * This configuration left here only for education proposes
 * And for work with database base PostGraphile api
 * if you need some additional information about how it work please follow: https://www.graphile.org/postgraphile/quick-start-guide/
 */

const PgSimplifyInflectorPlugin = require("@graphile-contrib/pg-simplify-inflector");

['AUTH_DATABASE_URL', 'NODE_ENV', 'GRAPHQL_SCHEMA_PATH', 'JSON_SCHEMA'].forEach(envvar => {
   if (!process.env[envvar]) {
      // We automatically source `.env` in the various scripts; but in case that
      // hasn't been done lets raise an error and stop.
      console.error("");
      console.error("");
      console.error("⚠️⚠️⚠️⚠️");
      console.error(`No ${envvar} found in your environment; perhaps you need to run 'source ./.env'?`);
      console.error("⚠️⚠️⚠️⚠️");
      console.error("");
      process.exit(1);
   }
});

const isDev = process.env.NODE_ENV === "development";
if(!isDev)
   throw new Error("Default PostGraphile allowed only on development in current project")

// Our database URL - privileged
const ownerConnection = process.env.ROOT_DATABASE_URL;
// Our database URL
const connection = process.env.AUTH_DATABASE_URL;
// The PostgreSQL schema within our postgres DB to expose
const schema = ["app_public"];
// Enable GraphiQL interface
const graphiql = true;
// Send back JSON objects rather than JSON strings
const dynamicJson = true;
// Watch the database for changes
const watch = true;
// Add some Graphile-Build plugins to enhance our GraphQL schema
const appendPlugins = [
   // Removes the 'ByFooIdAndBarId' from the end of relations
   PgSimplifyInflectorPlugin,
];


module.exports = {
   // Options for the CLI:
   options: {
      ownerConnection,
      defaultRole: "orange_visitor",
      connection,
      schema,
      dynamicJson,
      enhanceGraphiql: true,
      disableGraphiql: !graphiql,
      ignoreRbac: false,
      // We don't set a watch mode here, because there's no way to turn it off (e.g. when using -X) currently.
      appendPlugins,
   },
};
