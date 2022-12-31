local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";

local storageClass = k.storage.v1.storageClass;

function(mode) [
  storageClass.new(vars.longhorn.singleReplicaStorageClass) +
  storageClass.withProvisioner("driver.longhorn.io") +
  storageClass.withAllowVolumeExpansion(true) +
  storageClass.withReclaimPolicy("Delete") +
  storageClass.withVolumeBindingMode("Immediate") +
  storageClass.withParameters({
    numberOfReplicas: "1",
    staleReplicaTimeout: "2880", # 48 hours in minutes
    fromBackup: "",
    fsType: "ext4",
  })
]
