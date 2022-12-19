local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "kubernetes-reflector",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '1',
      },
    },
    spec: {
      project: vars.argo.project,
      source: {
        repoURL: 'https://emberstack.github.io/helm-charts',
        targetRevision: '0.1.0',
        chart: 'reflector',
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.kubernetes_reflector.namespace,
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
