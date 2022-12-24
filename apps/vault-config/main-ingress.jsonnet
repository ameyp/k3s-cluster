local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';
local service_name = 'vault-ui';

{
  apiVersion: "traefik.containo.us/v1alpha1",
  kind: "IngressRouteTCP",
  metadata: {
    name: "vault",
    namespace: vars.vault.namespace,
  },
  spec: {
    entryPoints: ["websecure",],
    routes: [{
      match: std.format("HostSNI(`%s`)",
                        [k.get_endpoint(vars.vault.main.ingress.subdomain)]),
      services: [{
        name: service_name,
        port: vars.vault.main.ingress.port,
        weight: 1,
      }],
    }],
    tls: {
      passthrough: true,
    }
  }
}
