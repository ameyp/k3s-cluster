local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';

function(mode='test') [{
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
                        [wirywolf.get_endpoint(vars.vault.main.ingress.subdomain, mode)]),
      services: [{
        name: "vault-ui",
        port: vars.vault.main.ingress.port,
        weight: 1,
      }],
    }],
    tls: {
      passthrough: true,
    }
  }
}]
