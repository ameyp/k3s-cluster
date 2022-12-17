local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';
local service_name = 'vault-unsealer';

{
  apiVersion: "traefik.containo.us/v1alpha1",
  kind: "IngressRouteTCP",
  metadata: {
    name: "vault-unsealer",
    namespace: vars.vault_unsealer.namespace,
  },
  spec: {
    entryPoints: ["websecure",],
    routes: [{
      match: std.format("HostSNI(`%s`)",
                        [k.get_endpoint(vars.vault_unsealer.ingress.subdomain)]),
      services: [{
        name: service_name,
        port: vars.vault_unsealer.ingress.port,
        weight: 1,
      }],
    }],
    tls: {
      secretName: vars.vault_unsealer.ingress.cert_secret,
      passthrough: true,
    }
  }
}
