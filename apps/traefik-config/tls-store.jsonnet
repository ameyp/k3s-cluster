local vars = import 'variables.libsonnet';

# https://doc.traefik.io/traefik/https/tls/#default-certificate
{
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
}
