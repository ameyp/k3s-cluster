local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';
local initializer = import './initializer-job.libsonnet';

function(mode='test') [initializer(
  "vault-unsealer-initializer",
  wirywolf.get_endpoint(vars.vault.unsealer.ingress.subdomain, mode),
  ["-vault-for-autounseal"])]
