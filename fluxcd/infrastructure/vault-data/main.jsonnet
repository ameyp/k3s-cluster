local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomizations = import "./kustomizations.libsonnet";
local configuration = import "./configuration.libsonnet";
local policies = import "./policies.libsonnet";
local kubernetes_roles = import "./kubernetes_roles.libsonnet";
local database_mounts = import "./database-mounts.libsonnet";
local database_engines = import "./database-engines.libsonnet";
local database_roles = import "./database-roles.libsonnet";

local databasesPath = "databases";
local postgresqlMountName = "postgresql";
local mariadbMountName = "mariadb";

function(mode)
  kustomizations(mode) +
  configuration(mode) +
  policies(mode) +
  kubernetes_roles(mode) +
  database_mounts(mode, {
    path: databasesPath,
    postgresql: {
      name: postgresqlMountName,
    },
    mariadb: {
      name: mariadbMountName,
    }
  }) +
  database_engines(mode, {
    postgresql: {
      path: "%s/%s" % [databasesPath, postgresqlMountName],
      endpoint: wirywolf.get_endpoint(vars.databases.postgresql.subdomain, mode),
    },
    mariadb: {
      path: "%s/%s" % [databasesPath, mariadbMountName],
      endpoint: wirywolf.get_endpoint(vars.databases.mariadb.subdomain, mode),
    }
  }) +
  database_roles(mode, {
    postgresql: {
      path: "%s/%s" % [databasesPath, postgresqlMountName],
    },
    mariadb: {
      path: "%s/%s" % [databasesPath, mariadbMountName],
    }
  })
