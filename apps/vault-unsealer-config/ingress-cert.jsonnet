local vars = import 'variables.libsonnet';
local k = import '../vendor/k8s.libsonnet';

{
  apiVersion: "cert-manager.io/v1",
  kind: "Certificate",
  metadata: {
    name: "vault-unsealer-web-cert",
    namespace: vars.vault_unsealer.namespace,
  },
  spec: {
    dnsNames: [
      k.get_endpoint(vars.vault_unsealer.ingress.subdomain),
    ],
    issuerRef: {
      name: vars.cert_manager.lets_encrypt_issuer,
      kind: "ClusterIssuer",
    },
    secretName: vars.vault_unsealer.ingress.cert_secret,
    usages: ["server auth"],
  },
}
