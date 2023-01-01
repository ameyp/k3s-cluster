local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";

local secret = k.core.v1.secret;

function(mode) [
  // Create the secret containing the initial admin password
  secret.new(vars.databases.postgresql.initialPasswordSecret, {}) +
  secret.metadata.withNamespace(vars.databases.namespace) +
  secret.withStringData({
    "postgres-password": vars.databases.postgresql.initialPassword
  }),

  // Helm repo and chart
  {
    apiVersion: "source.toolkit.fluxcd.io/v1beta2",
    kind: "HelmRepository",
    metadata: {
      name: "bitnami",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "24h",
      url: "https://charts.bitnami.com/bitnami"
    }
  },
  {
    apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
    kind: "HelmRelease",
    metadata: {
      name: "postgresql",
      namespace: vars.flux.namespace,
    },
    spec: {
      targetNamespace: vars.databases.namespace,
      dependsOn: [
        {name: "longhorn"},
        {name: "metallb"},
      ],
      interval: "30m",
      install: {
        createNamespace: true,
      },
      releaseName: "postgresql",
      chart: {
        spec: {
          chart: "postgresql",
          version: "11.6.8",
          sourceRef: {
            kind: "HelmRepository",
            name: "bitnami",
            namespace: vars.flux.namespace,
          },
          interval: "12h",
        },
      },
      values: {
        global: {
          storageClass: "longhorn",
          postgresql: {
            auth: {
              existingSecret: vars.databases.postgresql.initialPasswordSecret,
            }
          }
        },
        tls: {
          enabled: true,
          certificatesSecret: vars.cluster.wildcard_cert_secret,
          certFilename: "tls.crt",
          certKeyFilename: "tls.key",
        },
        primary: {
          persistence: {
            storageClass: "longhorn",
            size: "1Gi",
          },
          service: {
            type: "LoadBalancer",
            loadBalancerIP: if mode == 'test'
                            then vars.databases.postgresql.testLoadBalancerIP
                            else vars.databases.postgresql.loadBalancerIP,
          }
        }
      },
    },
  }
]
