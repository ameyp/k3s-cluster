local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local allowed_namespaces = std.join(",", [
  vars.vault.namespace,
  vars.argo.namespace
]);

local auto_namespaces = std.join(",", [
  vars.vault.namespace
]);

function(mode='test') [{
  apiVersion: "cert-manager.io/v1",
  kind: "Certificate",
  metadata: {
    name: "wildcard-web-cert",
    namespace: 'default',
    annotations: {
      'argocd.argoproj.io/sync-wave': '2',
    },
  },
  spec: {
    dnsNames: [
      wirywolf.get_endpoint("*", mode),
    ],
    issuerRef: {
      name: vars.cert_manager.lets_encrypt_issuer,
      kind: "ClusterIssuer",
    },
    secretName: vars.cluster.wildcard_cert_secret,
    secretTemplate: {
      annotations: {
        "reflector.v1.k8s.emberstack.com/reflection-allowed": "true",
        "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces": allowed_namespaces,
        "reflector.v1.k8s.emberstack.com/reflection-auto-enabled": "true",
        "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces": auto_namespaces,
      },
    },
    usages: ["server auth"],
  },
}, {
  apiVersion: "cert-manager.io/v1",
  kind: "Certificate",
  metadata: {
    name: vars.vault.main.internalCertSecret,
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
    secretName: vars.vault.main.internalCertSecret,
    usages: ["server auth"],
  },
}]
