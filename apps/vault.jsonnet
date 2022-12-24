local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');
local k = import 'k8s.libsonnet';

function(mode='test') [
  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: 'vault',
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '5',
      },
      finalizers: ["resources-finalizer.argocd.argoproj.io"],
    },
    spec: {
      project: vars.argo.project,
      sources: [
        {
          repoURL: 'https://helm.releases.hashicorp.com',
          targetRevision: '0.21.0',
          chart: 'vault',
          helm: {
            releaseName: 'vault-unsealer',
            values: (importstr "files/vault-unsealer/values.yaml") % {
              secret_name: vars.cluster.wildcard_cert_secret,
            },
          }
        },
        {
          repoURL: 'https://helm.releases.hashicorp.com',
          targetRevision: '0.21.0',
          chart: 'vault',
          helm: {
            releaseName: 'vault',
            values: (importstr "files/vault/values.yaml") % {
              webPort: vars.vault.main.ingress.port,
              replicas: if mode == 'test' then vars.vault.main.testReplicas else vars.vault.main.prodReplicas,
              tlsSecret: vars.vault.main.internalCertSecret,
              webSecret: vars.cluster.wildcard_cert_secret,
            },
          }
        },
        // {
        //   repoURL: 'https://redhat-cop.github.io/vault-config-operator',
        //   targetRevision: '0.8.4',
        //   chart: 'vault-config-operator',
        //   helm: {
        //     releaseName: 'vault-unsealer-operator',
        //     values: (importstr "files/vault-unsealer-operator/values.yaml") % {
        //       vaultAddr: "https://%s" % k.get_endpoint(vars.vault.unsealer.ingress.subdomain),
        //     },
        //   }
        // },
        {
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
