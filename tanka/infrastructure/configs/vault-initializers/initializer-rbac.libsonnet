local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';

function(mode='test') [
  wirywolf.service_account.new({
    name: vars.vault.initializer.service_account,
    namespace: vars.vault.namespace,
  }),
  wirywolf.role.new({
    name: vars.vault.initializer.service_account,
    namespace: vars.vault.namespace,
    rules: [{
      apiGroups: [""],
      resources: ["secrets"],
      verbs: ["*"]
    }],
  }),
  wirywolf.role_binding.new({
    name: vars.vault.initializer.service_account,
    namespace: vars.vault.namespace,
    roleRef: vars.vault.initializer.service_account,
    subjects: [{
      kind: "ServiceAccount",
      name: vars.vault.initializer.service_account
    }],
  }),
]
