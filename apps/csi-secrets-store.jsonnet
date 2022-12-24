local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "csi-secrets-store",
      namespace: vars.argo.namespace,
    },
    spec: {
      project: vars.argo.project,
      sources: [{
        repoURL: 'https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts',
        targetRevision: '1.2.4',
        chart: 'secrets-store-csi-driver',
        helm: {
          parameters: [{
            name: "syncSecret.enabled",
            value: true
          }],
        },
      }],
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.vault.namespace,
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
]
