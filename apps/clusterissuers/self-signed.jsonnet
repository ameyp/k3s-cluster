local vars = import 'variables.libsonnet';

{
  apiVersion: "cert-manager.io/v1",
  kind: "ClusterIssuer",
  metadata: {
    name: vars.cert_manager.self_signed_issuer,
    annotations: {
      'argocd.argoproj.io/sync-wave': '3',
    },
  },
  spec: {
    selfSigned: {}
  }
}
