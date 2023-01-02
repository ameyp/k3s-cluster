local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomizations = import "./kustomizations.libsonnet";
local configuration = import "./configuration.libsonnet";
local policies = import "./policies.libsonnet";
local kubernetes_roles = import "./kubernetes_roles.libsonnet";
local database_mounts = import "./database-mounts.libsonnet";
local database_engines = import "./database-engines.libsonnet";

local postgresPath = "postgres";
local mariadbPath = "mariadb";
local adminPasswordSecret = "database-vault-password";

function(mode)
  kustomizations(mode) +
  configuration(mode, adminPasswordSecret) +
  policies(mode) +
  kubernetes_roles(mode) +
  database_mounts(mode, {
    postgresql: {
      path: postgresPath,
      endpoint: wirywolf.get_endpoint(vars.databases.postgresql.subdomain, mode),
      passwordSecret: adminPasswordSecret,
    },
    mariadb: {
      path: mariadbPath,
      endpoint: wirywolf.get_endpoint(vars.databases.mariadb.subdomain, mode),
      passwordSecret: adminPasswordSecret,
    }
  })
