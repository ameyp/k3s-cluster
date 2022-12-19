local vars = import 'variables.libsonnet';

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "argocd-config",
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
        path: "apps/argocd-config",
        directory: {
          jsonnet: {
            libs: ["vendor"],
            extVars: [{
              name: 'mode',
              value: 'test',
            }]
          },
        },
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.argo.namespace,
      },
      ignoreDifferences: [
        # Ignored because this is reflected from the wildcard cert's secret.
        {
          group: "core",
          kind: "Secret",
          name: vars.argo.tls_secret_name,
          jqPathExpressions: [
            ".data"
          ],
        }
      ],
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
