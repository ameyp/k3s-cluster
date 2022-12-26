local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "cert-manager.io/v1",
  kind: "ClusterIssuer",
  metadata: {
    name: vars.cert_manager.lets_encrypt_issuer,
    annotations: {
      'argocd.argoproj.io/sync-wave': '1',
    },
  },
  spec: {
    acme: {
      privateKeySecretRef: {
        name: vars.cert_manager.lets_encrypt_issuer,
      },
      server: "https://acme-v02.api.letsencrypt.org/directory",
      solvers:[{
        dns01: {
          cloudflare: {
            apiTokenSecretRef: {
              key: "apitoken",
              name: "cloudflare-api-token"
            }
          }
        }
      }]
    }
  }
}, {
  apiVersion: "cert-manager.io/v1",
  kind: "ClusterIssuer",
  metadata: {
    name: vars.cert_manager.self_signed_issuer,
    annotations: {
      'argocd.argoproj.io/sync-wave': '1',
    },
  },
  spec: {
    selfSigned: {}
  }
}]
