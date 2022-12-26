local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';

function(mode='test') [{
  apiVersion: "traefik.containo.us/v1alpha1",
  kind: "IngressRouteTCP",
  metadata: {
    name: "vault-unsealer",
    namespace: vars.vault.namespace,
  },
  spec: {
    entryPoints: ["websecure",],
    routes: [{
      match: std.format("HostSNI(`%s`)",
                        [wirywolf.get_endpoint(vars.vault.unsealer.ingress.subdomain, mode)]),
      services: [{
        name: "vault-unsealer",
        port: vars.vault.unsealer.ingress.port,
        weight: 1,
      }],
    }],
    tls: {
      passthrough: true,
    }
  }
}]
