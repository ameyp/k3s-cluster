local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';
local service_name = 'argocd-server';

{
  apiVersion: "traefik.containo.us/v1alpha1",
  kind: "IngressRoute",
  metadata: {
    name: "argocd-server",
    namespace: vars.argo.namespace,
  },
  spec: {
    entryPoints: ["websecure",],
    routes: [{
      kind: "Rule",
      match: std.format("Host(`%s`)",
                        [k.get_endpoint(vars.argo.ingress.subdomain)]),
      priority: 10,
      services: [{
        name: service_name,
        port: vars.argo.ingress.port,
      }],
    }, {
      kind: "Rule",
      match: std.format("Host(`%s`) && Headers(`Content-Type`, `application/grpc`)",
                        [k.get_endpoint(vars.argo.ingress.subdomain)]),
      priority: 11,
      services: [{
        name: service_name,
        port: vars.argo.ingress.port,
        scheme: "h2c",
      }],
    }],
    tls: {}
  }
}
