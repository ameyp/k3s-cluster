local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";

local postgresql = import "./postgresql.libsonnet";
local mariadb = import "./mariadb.libsonnet";

function(mode) [
  // Create the namespace
  k.core.v1.namespace.new(vars.databases.namespace),
] + postgresql(mode) + mariadb(mode)
