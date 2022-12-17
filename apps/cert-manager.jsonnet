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
      sources: [{
        repoURL: 'https://charts.jetstack.io',
        targetRevision: '1.10.1',
        chart: 'cert-manager',
        helm: {
          values: importstr "files/cert-manager/values.yaml",
        }
      }, {
        repoURL: 'https://github.com/ameyp/k3s-cluster',
        targetRevision: 'main',
        path: "apps/clusterissuers",
        directory: {
          jsonnet: {
            libs: ["vendor"]
          },
        },
      }],
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
]
