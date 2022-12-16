local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "prometheus-crds",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '1',
      },
    },
    spec: {
      project: vars.argo.project,
      source: {
        repoURL: 'https://github.com/prometheus-community/helm-charts',
        targetRevision: 'main',
        path: 'charts/kube-prometheus-stack/crds',
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: 'argocd',
      },
      syncPolicy: {
        automated: {
          selfHeal: true,
        },
        syncOptions: [
          'Validate=false',
          'CreateNamespace=true',
          # https://github.com/argoproj/argo-cd/issues/820
          'ServerSideApply=true'
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
