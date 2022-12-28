local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "metallb.io/v1beta1",
  kind: "IPAddressPool",
  metadata: {
    name: vars.metallb.pool_name,
    namespace: vars.metallb.namespace,
  },
  spec: {
    addresses: [if mode == 'test' then vars.metallb.test_ip_block else vars.metallb.ip_block]
  }
}, {
  apiVersion: "metallb.io/v1beta1",
  kind: "L2Advertisement",
  metadata: {
    name: "external",
    namespace: vars.metallb.namespace,
  },
  spec: {
    ipAddressPools: [vars.metallb.pool_name],
  },
}]
