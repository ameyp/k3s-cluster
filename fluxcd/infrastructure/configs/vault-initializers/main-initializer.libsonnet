local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';
local initializer = import './initializer-job.libsonnet';

function(mode) [initializer(
  name="vault-main-initializer",
  # We cannot send the request to the hostname pointing at the LoadBalancer
  # because the UI service is set to only direct traffic to ready pods.
  addr="https://vault.%s.svc:8200" % vars.vault.namespace,
  args=[],
  secretName=vars.vault.main.internalCertSecret)]
