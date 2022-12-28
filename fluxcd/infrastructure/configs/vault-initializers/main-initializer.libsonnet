local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';
local initializer = import './initializer-job.libsonnet';

function(mode='test') [initializer(
  "vault-main-initializer",
  "https://%s" % wirywolf.get_endpoint(vars.vault.main.ingress.subdomain, mode),
  [])]
