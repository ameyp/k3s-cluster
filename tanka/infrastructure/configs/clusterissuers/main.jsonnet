local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "cert-manager.io/v1",
  kind: "ClusterIssuer",
  metadata: {
    name: vars.cert_manager.lets_encrypt_issuer,
  },
  spec: {
    acme: {
      privateKeySecretRef: {
        name: vars.cert_manager.lets_encrypt_issuer,
      },
      server: if mode == "test"
              then "https://acme-staging-v02.api.letsencrypt.org/directory"
              else "https://acme-v02.api.letsencrypt.org/directory",
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
  },
  spec: {
    selfSigned: {}
  }
}]

