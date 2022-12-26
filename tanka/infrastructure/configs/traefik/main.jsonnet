local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "traefik.containo.us/v1alpha1",
  kind: "TLSStore",
  metadata: {
    name: "default",
    namespace: "default",
  },
  spec: {
    defaultCertificate: {
      secretName: vars.cluster.wildcard_cert_secret,
    },
  },
}]
