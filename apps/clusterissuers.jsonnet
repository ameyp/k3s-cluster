local vars = import 'variables.libsonnet';

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "clusterissuers",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '3',
      },
    },
    spec: {
      project: vars.argo.project,
      source: {
        repoURL: 'https://github.com/ameyp/k3s-cluster',
        targetRevision: 'main',
        path: "apps/clusterissuers",
        directory: {
          jsonnet: {
            libs: ["vendor"]
          },
        },
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.argo.namespace,
      },
      syncPolicy: {
        automated: {
          selfHeal: true,
        },
        syncOptions: [
          'Validate=false',
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
  }
]
