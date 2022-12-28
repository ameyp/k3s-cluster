local vars = import "variables.libsonnet";

function(name, mode) {
  interval: "10m",
  sourceRef: {
    kind: "GitRepository",
    name: "k3s-cluster-deploy",
  },
  path: "./fluxcd/manifests/%s/infrastructure/configs/%s" % [mode, name],
  prune: true,
  wait: true,
}
