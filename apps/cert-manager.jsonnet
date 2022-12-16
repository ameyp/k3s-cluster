local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "cert-manager",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '2',
      },
    },
    spec: {
      project: vars.argo.project,
      source: {
        repoURL: 'https://charts.jetstack.io',
        targetRevision: '1.10.1',
        chart: 'cert-manager',
        helm: {
          values: importstr "files/cert-manager/values.yaml",
        },
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.cert_manager.namespace,
      },
      syncPolicy: {
        automated: {
          selfHeal: true,
        },
        syncOptions: [
          'Validate=false',
          'CreateNamespace=true',
        ],
        retry: {
          limit: 2,
          backoff: {
            duration: '5s',
            factor: 2,
            maxDuration: '3m',
          },
        },
      },
    },
  },
  {
    apiVersion: "cert-manager.io/v1",
    kind: "ClusterIssuer",
    metadata: {
      name: vars.cert_manager.lets_encrypt_issuer,
      annotations: {
        'argocd.argoproj.io/sync-wave': '3',
      },
    },
    spec: {
      acme: {
        privateKeySecretRef: {
          name: vars.cert_manager.lets_encrypt_issuer,
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
    }
  },
  {
    apiVersion: "cert-manager.io/v1",
    kind: "ClusterIssuer",
    metadata: {
      name: vars.cert_manager.self_signed_issuer,
      annotations: {
        'argocd.argoproj.io/sync-wave': '3',
      },
    },
    spec: {
      selfSigned: {}
    }
  },
]
