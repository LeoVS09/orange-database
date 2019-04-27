import PgSimplifyInflectorPlugin from "@graphile-contrib/pg-simplify-inflector"

const isDev = process.env.NODE_ENV === "development";

// Our database URL - privileged
const ownerConnection = process.env.ROOT_DATABASE_URL;

// Our database URL
export const connection = process.env.AUTH_DATABASE_URL;

// The PostgreSQL schema within our postgres DB to expose
export const schema = ["app_public"];

// Export graphql schema on startup
const exportGqlSchemaPath = process.env.GRAPHQL_SCHEMA_PATH;
const exportJsonSchemaPath = process.env.JSON_SCHEMA_PATH;

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

// PostGraphile introspection cache, use for improve startup time
const cachePath =  process.env.PG_CACHE_PATH

// Write cache on building
const writeCache = isDev ? cachePath : undefined

// Read cache in production
const readCache = !isDev ? cachePath : undefined

export const options = {
   ownerConnectionString: ownerConnection,
   exportGqlSchemaPath,
   exportJsonSchemaPath,
   dynamicJson,
   graphiql,
   watchPg: watch,
   appendPlugins,
   ignoreRBAC: false,
   writeCache,
   readCache
}
