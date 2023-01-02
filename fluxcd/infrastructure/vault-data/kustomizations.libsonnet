local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";
local kustomization = wirywolf.kustomization.new;

function(mode) {
  "kustomizations/configuration.yaml": kustomization({
    metadata: {
      name: "vault-data-configuration",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-data/configuration" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/kubernetes_roles.yaml": kustomization({
    metadata: {
      name: "vault-data-kubernetes-roles",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-data/kubernetes-roles" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/policies.yaml": kustomization({
    metadata: {
      name: "vault-data-policies",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-data/policies" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/database-mounts.yaml": kustomization({
    metadata: {
      name: "vault-data-database-mounts",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "vault-data-kubernetes-roles"
      }, {
        name: "vault-data-policies"
      }],
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-data/database-mounts" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/database-engines.yaml": kustomization({
    metadata: {
      name: "vault-data-database-engines",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "vault-data-database-mounts"
      }, {
        name: "vault-data-configuration"
      }],
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-data/database-engines" % mode,
      prune: true,
      wait: true,
    }
  }),
}
