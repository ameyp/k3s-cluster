local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';

{
  apiVersion: "cert-manager.io/v1",
  kind: "Certificate",
  metadata: {
    name: vars.vault.internalCertSecret,
    namespace: vars.vault.namespace,
  },
  spec: {
    dnsNames: [
      "*.vault-internal",
    ],
    issuerRef: {
      name: vars.cert_manager.self_signed_issuer,
      kind: "ClusterIssuer",
    },
    secretName: vars.vault.internalCertSecret,
    usages: ["server auth"],
  },
}
