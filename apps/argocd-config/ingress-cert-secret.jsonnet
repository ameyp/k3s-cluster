local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';

# https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/
k.secret.new({
  name: "argocd-server-tls",
  namespace: vars.argo.namespace,
  annotations: {
    "reflector.v1.k8s.emberstack.com/reflects": "default/%s" % vars.cluster.wildcard_cert_secret,
  }
})
