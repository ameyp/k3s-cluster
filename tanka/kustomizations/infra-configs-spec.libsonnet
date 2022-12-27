local vars = import "variables.libsonnet";

function(name, mode) {
  interval: "10m",
  targetNamespace: vars.flux.namespace,
  sourceRef: {
    kind: "GitRepository",
    name: "k3s-cluster-deploy",
  },
  path: "./tanka/manifests/%s/infrastructure/configs/%s" % [mode, name],
  prune: true,
  wait: true,
}
