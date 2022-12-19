local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "traefik",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '4',
      },
    },
    spec: {
      project: vars.argo.project,
      sources: [{
        repoURL: 'https://helm.traefik.io/traefik',
        targetRevision: '20.8.0',
        chart: 'traefik',
        helm: {
          values: (importstr "files/traefik/values.yaml")  % {
            load_balancer_ip: if mode == 'test' then vars.traefik.test_load_balancer_ip else vars.load_balancer_ip,
          },
        },
      }, {
        repoURL: 'https://github.com/ameyp/k3s-cluster',
        targetRevision: 'main',
        path: "apps/traefik-config",
        directory: {
          jsonnet: {
            libs: ["vendor"]
          },
        },
      }],
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.traefik.namespace,
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
