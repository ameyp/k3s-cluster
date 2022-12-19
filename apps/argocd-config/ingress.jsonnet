local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';
local service_name = 'argocd-server';

{
  apiVersion: "traefik.containo.us/v1alpha1",
  kind: "IngressRouteTCP",
  metadata: {
    name: "argocd-server",
    namespace: vars.argo.namespace,
  },
  spec: {
    entryPoints: ["websecure",],
    routes: [{
      match: std.format("HostSNI(`%s`)",
                        [k.get_endpoint(vars.argo.ingress.subdomain)]),
      services: [{
        name: service_name,
        port: vars.argo.ingress.port,
        weight: 1,
      }],
    }],
    tls: {
      passthrough: true,
    }
  }
}
