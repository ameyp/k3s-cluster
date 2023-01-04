local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';
local initializer = import './initializer-job.libsonnet';

function(mode='test') [initializer(
  name="vault-unsealer-initializer",
  addr="https://%s" % wirywolf.get_endpoint(vars.vault.unsealer.ingress.subdomain, mode),
  args=["-vault-for-autounseal"],
  secretName=vars.cluster.wildcard_cert_secret)]
