local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

function(mode) {
  "release/repo.yaml": wirywolf.helmRepository.new("vault-config-operator", "https://redhat-cop.github.io/vault-config-operator"),
  "release/release.yaml": wirywolf.helmRelease.new({
    name: "vault-config-operator",
    spec: {
      targetNamespace: vars.vault.namespace,
      interval: "30m",
      releaseName: "vault-config-operator",
      chart: {
        spec: {
          chart: "vault-config-operator",
          version: "0.8.4",
          sourceRef: {
            kind: "HelmRepository",
            name: "vault-config-operator",
            namespace: vars.flux.namespace,
          },
          interval: "12h",
        },
      },
      values: {
        env: [{
          name: "VAULT_ADDR",
          value: wirywolf.get_vault_address(mode)
        }]
      },
      postRenderers: [{
        kustomize: {
          patchesJson6902: [{
            target: {
              version: "v1",
              kind: "Deployment",
              name: "vault-config-operator",
            },
            patch: [{
              op: "add",
              path: "/spec/template/spec/volumes",
              value: {
                name: "vault-tls-certs",
                secret: {
                  secretName: vars.cluster.wildcard_cert_secret
                }
              }
            }, {
              op: "add",
              path: "/spec/template/spec/containers/1/volumeMounts",
              value: {
                name: "vault-tls-certs",
                mountPath: "/vault-tls"
              }
            }, {
              op: "add",
              path: "/spec/template/spec/containers/1/env",
              value: {
                name: "VAULT_CACERT",
                value: "/vault-tls/tls.crt"
              },
            }]
          }]
        }
      }]
    }
  }),
  "release/kustomization.yaml": {
    apiVersion: "kustomize.config.k8s.io/v1beta1",
    kind: "Kustomization",
    resources: ["repo.yaml", "release.yaml"],
    patches: [{
      target: {
        kind: "Deployment",
        labelSelector: "app.kubernetes.io/name=vault-config-operator"
      },
      patch: |||
        - op: "add"
          path: "/spec/template/spec/volumes"
          value:
            name: "vault-tls-certs"
            secret:
              secretName: vars.cluster.wildcard_cert_secret
        - op: "add"
          path: "/spec/template/spec/containers/1/volumeMounts"
          value:
            name: "vault-tls-certs"
            mountPath: "/vault-tls"
        - op: "add"
          path: "/spec/template/spec/containers/1/env"
          value:
            name: "VAULT_CACERT"
            value: "/vault-tls/tls.crt"
      |||
    }]
  }
}

