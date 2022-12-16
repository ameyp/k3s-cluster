local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

{
  apiVersion: "metallb.io/v1beta1",
  kind: "IPAddressPool",
  metadata: {
    name: vars.metallb.pool_name,
    namespace: vars.metallb.namespace,
  },
  spec: {
    addresses: [if mode == 'test' then vars.metallb.test_ip_block else vars.metallb.ip_block]
  }
}
