local vars = import 'variables.libsonnet';

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
      source: {
        repoURL: 'https://helm.traefik.io/traefik',
        targetRevision: '2.9.6',
        chart: 'traefik',
        helm: {
          values: (importstr "files/traefik/values.yaml")  % {
            load_balancer_ip: vars.traefik.load_balancer_ip,
          },
        },
      },
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
