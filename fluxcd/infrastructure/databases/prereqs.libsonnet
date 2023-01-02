local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";

function(mode) {
  // Create the namespace
  "prereqs/main.yaml": k.core.v1.namespace.new(vars.databases.namespace),
}
