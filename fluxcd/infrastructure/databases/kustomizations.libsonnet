local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";
local kustomization = wirywolf.kustomization.new;

function(mode) {
  "kustomizations/prereqs.yaml": kustomization({
    metadata: {
      name: "infra-databases-prereqs",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/databases/prereqs" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/postgresql-prereqs.yaml": kustomization({
    metadata: {
      name: "infra-databases-postgresql-prereqs",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/databases/postgresql-prereqs" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/postgresql.yaml": kustomization({
    metadata: {
      name: "infra-databases-postgresql",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "infra-databases-postgresql-prereqs"
      }],
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/databases/postgresql" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/mariadb-prereqs.yaml": kustomization({
    metadata: {
      name: "infra-databases-mariadb-prereqs",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/databases/mariadb-prereqs" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/mariadb.yaml": kustomization({
    metadata: {
      name: "infra-databases-mariadb",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "infra-databases-mariadb-prereqs"
      }],
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/databases/mariadb" % mode,
      prune: true,
      wait: true,
    }
  })
}
