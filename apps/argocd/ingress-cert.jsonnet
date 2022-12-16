local vars = import 'variables.libsonnet';
local k = import '../vendor/k8s.libsonnet';

{
  apiVersion: "cert-manager.io/v1",
  kind: "Certificate",
  metadata: {
    name: "vault-web-cert",
    namespace: vars.argo.namespace,
  },
  spec: {
    dnsNames: [
      k.get_endpoint(vars.argo.ingress.subdomain),
    ],
    issuerRef: {
      name: vars.cert_manager.lets_encrypt_issuer,
      kind: "ClusterIssuer",
    },
    secretName: vars.argo.ingress.cert_secret,
    usages: ["server auth"],
  },
}
