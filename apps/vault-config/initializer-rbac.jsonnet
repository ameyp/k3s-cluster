local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';

[
  k.service_account.new({
    name: vars.vault.initializer.service_account,
    namespace: vars.vault.namespace,
  }),
  k.role.new({
    name: vars.vault.initializer.service_account,
    namespace: vars.vault.namespace,
    rules: [{
      apiGroups: [""],
      resources: ["secrets"],
      verbs: ["*"]
    }]
  }),
  k.role_binding.new({
    name: vars.vault.initializer.service_account,
    namespace: vars.vault.namespace,
    roleRef: vars.vault.initializer.service_account,
    subjects: [{
      kind: "ServiceAccount",
      name: vars.vault.initializer.service_account
    }]
  }),
]
