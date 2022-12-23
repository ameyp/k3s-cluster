local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';

{
  apiVersion: "cert-manager.io/v1",
  kind: "Certificate",
  metadata: {
    name: vars.vault.internalCertSecret,
    namespace: vars.vault.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '2',
    },
  },
  spec: {
    dnsNames: [
      "*.vault-internal",
    ],
    ipAddresses: [
      "127.0.0.1",
    ],
    issuerRef: {
      name: vars.cert_manager.self_signed_issuer,
      kind: "ClusterIssuer",
    },
    secretName: vars.vault.internalCertSecret,
    usages: ["server auth"],
  },
}
