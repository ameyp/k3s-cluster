local vars = import "variables.libsonnet";

function(name) {
  name: "infra-configs-%s" % name,
  namespace: vars.flux.namespace,
}
