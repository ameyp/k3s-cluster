local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';

local target_namespaces = std.join(",", [
  vars.vault_unsealer.namespace
]);

{
  apiVersion: "cert-manager.io/v1",
  kind: "Certificate",
  metadata: {
    name: "wildcard-web-cert",
    namespace: 'default',
  },
  spec: {
    dnsNames: [
      k.get_endpoint("*"),
    ],
    issuerRef: {
      name: vars.cert_manager.lets_encrypt_issuer,
      kind: "ClusterIssuer",
    },
    secretName: vars.cluster.wildcard_cert_secret,
    secretTemplate: {
      annotations: {
        "reflector.v1.k8s.emberstack.com/reflection-allowed": "true",
        "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces": target_namespaces,
        "reflector.v1.k8s.emberstack.com/reflection-auto-enabled": "true",
        "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces": target_namespaces,
      },
    },
    usages: ["server auth"],
  },
}
