local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "metallb",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '2',
      },
    },
    spec: {
      project: vars.argo.project,
      sources: [{
        repoURL: 'https://metallb.github.io/metallb',
        targetRevision: '0.13.7',
        chart: 'metallb',
        helm: {
          values: (importstr "files/metallb/values.yaml")  % {
            prometheus_label: vars.monitoring.prometheus_stack_name,
            prometheus_namespace: vars.monitoring.namespace,
          },
        },
      }, {
        repoURL: 'https://github.com/ameyp/k3s-cluster',
        targetRevision: 'main',
        path: "apps/metallb-config",
        directory: {
          jsonnet: {
            libs: ["vendor"],
            extVars: [{
              name: 'mode',
              value: 'test',
            }]
          },
        },
      }],
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.metallb.namespace,
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
