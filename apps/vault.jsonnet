local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "vault-unsealer",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '5',
      },
      finalizers: ["resources-finalizer.argocd.argoproj.io"],
    },
    spec: {
      project: vars.argo.project,
      sources: [{
        repoURL: 'https://helm.releases.hashicorp.com',
        targetRevision: '0.21.0',
        chart: 'vault',
        helm: {
          values: (importstr "files/vault-unsealer/values.yaml") % {
            secret_name: vars.cluster.wildcard_cert_secret,
          },
        }
      }, {
        repoURL: 'https://github.com/ameyp/k3s-cluster',
        targetRevision: 'main',
        path: "apps/vault-config",
        directory: {
          jsonnet: {
            libs: ["vendor"],
            extVars: [{
              name: 'mode',
              value: 'test',
            }],
          },
        },
      }],
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.vault.namespace,
      },
      ignoreDifferences: [{
        group: "admissionregistration.k8s.io",
        kind: "MutatingWebhookConfiguration",
        name: "vault-unsealer-agent-injector-cfg",
        jqPathExpressions: [
          ".webhooks[].clientConfig.caBundle"
        ],
      }],
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