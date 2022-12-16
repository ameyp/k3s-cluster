local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

{
  secret: {
    // Exports
    new: function(params) {
      apiVersion: "v1",
      kind: "Secret",
      metadata: {
        name: params.name,
        namespace: if std.objectHas(params, 'namespace') then params.namespace else "default",
      },
      type: if std.objectHas(params, 'type') then params.type else "Opaque",
      data: if std.objectHas(params, 'data') then params.data else {},
    },
  },
  get_endpoint: function(subdomain)
    if mode == 'test' then
      std.format("%s.%s.%s", [subdomain, vars.cluster.test_domain_prefix, vars.cluster.domain_name])
    else
      std.format("%s.%s", [subdomain, vars.cluster.domain])
}
