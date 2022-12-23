local vars = import 'variables.libsonnet';
local mode = std.extVar('mode');

local getOrDefault = function(params, name, default) if std.objectHas(params, name) then params[name] else default;

{
  secret: {
    // Exports
    new: function(params) {
      apiVersion: "v1",
      kind: "Secret",
      metadata: {
        name: params.name,
        namespace: getOrDefault(params, 'namespace', 'default'),
        annotations: getOrDefault(params, 'annotations', {})
      },
      type: getOrDefault(params, 'type', 'Opaque'),
      data: getOrDefault(params, 'data', {}),
    },
  },
  get_endpoint: function(subdomain)
    if mode == 'test' then
      std.format("%s.%s.%s", [subdomain, vars.cluster.test_domain_prefix, vars.cluster.domain_name])
    else
      std.format("%s.%s", [subdomain, vars.cluster.domain]),
  service_account: {
    new: function(params) {
      apiVersion: "v1",
      kind: "ServiceAccount",
      metadata: {
        name: params.name,
        namespace: getOrDefault(params, 'namespace', 'default'),
        annotations: getOrDefault(params, 'annotations', {})
      },
    },
  },
  role: {
    new: function(params) {
      apiVersion: "rbac.authorization.k8s.io/v1",
      kind: "Role",
      metadata: {
        name: params.name,
        namespace: getOrDefault(params, 'namespace', 'default'),
        annotations: getOrDefault(params, 'annotations', {})
      },
      rules: params.rules,
    },
  },
  role_binding: {
    new: function(params) {
      apiVersion: "rbac.authorization.k8s.io/v1",
      kind: "RoleBinding",
      metadata: {
        name: params.name,
        namespace: getOrDefault(params, 'namespace', 'default'),
        annotations: getOrDefault(params, 'annotations', {})
      },
      roleRef: {
        kind: "Role",
        name: params.roleRef,
        apiGroup: "rbac.authorization.k8s.io",
      },
      subjects: params.subjects
    },
  },
}
