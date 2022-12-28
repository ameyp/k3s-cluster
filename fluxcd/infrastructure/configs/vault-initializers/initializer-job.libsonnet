local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import 'variables.libsonnet';

local container = k.core.v1.container;
local job = k.batch.v1.job;
local jobSpec = k.batch.v1.job.spec.template.spec;
local envVar = k.core.v1.envVar;
local volume = k.core.v1.volume;
local volumeMount = k.core.v1.volumeMount;

local volumeName = "vault-tls-web";
local certName = "tls.crt";

function(name, addr, args)
  job.new(name) +
  job.metadata.withNamespace("vault") +
  jobSpec.withServiceAccountName(vars.vault.initializer.service_account) +
  jobSpec.withRestartPolicy("IfNotPresent") +
  jobSpec.withContainers([
    container.new("initializer", "ameypar/k8s-vault-initializer:latest") +
    container.withArgs(args) +
    container.withEnvMixin([
      envVar.new("VAULT_ADDR", addr),
      envVar.new("VAULT_CACERT", "/%s/%s" % [volumeName, certName])
    ]) +
    container.withVolumeMounts([
      volumeMount.new(volumeName, "/%s" % [volumeName])
    ])
  ]) +
  jobSpec.withVolumes([
    volume.fromSecret(volumeName, vars.cluster.wildcard_cert_secret)
  ])
