local vars = import 'variables.libsonnet';

{
  apiVersion: "metallb.io/v1beta1",
  kind: "L2Advertisement",
  metadata: {
    name: "external"
    namespace: vars.metallb.namespace,
  },
  spec: {
    ipAddressPools: [vars.metallb.pool_name],
  },
}
