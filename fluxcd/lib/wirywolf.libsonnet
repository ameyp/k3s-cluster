local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import 'variables.libsonnet';

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
  get_endpoint: function(subdomain, mode)
    if mode == 'test' then
      std.format("%s.%s.%s", [subdomain, vars.cluster.test_domain_prefix, vars.cluster.domain_name])
    else
      std.format("%s.%s", [subdomain, vars.cluster.domain_name]),
  get_vault_address: function(mode)
    if mode == 'test' then
      std.format("https://%s.%s.%s", ["vault", vars.cluster.test_domain_prefix, vars.cluster.domain_name])
    else
      std.format("https://%s.%s", ["vault", vars.cluster.domain_name]),
  get_controller_ip: function(mode)
    if mode == 'test' then vars.cluster.test_controller_ip else vars.cluster.controller_ip,
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
  kustomization: {
    new: function(params) {
      apiVersion: "kustomize.toolkit.fluxcd.io/v1beta2",
      kind: "Kustomization",
      metadata: params.metadata,
      spec: params.spec,
    }
  },
  helmRepository: {
    new: function(name, url) {
      apiVersion: "source.toolkit.fluxcd.io/v1beta2",
      kind: "HelmRepository",
      metadata: {
        name: name,
        namespace: vars.flux.namespace,
      },
      spec: {
        interval: "24h",
        url: url
      }
    }
  },
  helmRelease: {
    new: function(params) {
      apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
      kind: "HelmRelease",
      metadata: {
        name: params.name,
        namespace: vars.flux.namespace,
      },
      spec: params.spec
    }
  },
  persistentVolumeClaim: {
    local pvc = k.core.v1.persistentVolumeClaim,

    new: function(params)
        pvc.new(params.name) +
         pvc.metadata.withNamespace(params.namespace) +
         pvc.spec.withAccessModes(["ReadWriteMany"]) +
         pvc.spec.resources.withRequests({
           storage: params.storage
         }) +
         pvc.spec.withStorageClassName(vars.longhorn.defaultStorageClass)
  }
}
