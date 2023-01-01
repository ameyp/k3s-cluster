local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local configMap = k.core.v1.configMap;
local container = k.core.v1.container;
local containerPort = k.core.v1.containerPort;
local envVar = k.core.v1.envVar;
local service = k.core.v1.service;
local servicePort = k.core.v1.servicePort;
local statefulSet = k.apps.v1.statefulSet;
local volume = k.core.v1.volume;
local volumeMount = k.core.v1.volumeMount;

local configPvcName = "mariadb-data";
local configMapName = "mariadb-config";
local certsVolumeName = "mariadb-certs";
local serviceName = "mariadb";

function(mode) [
  // PVC
  wirywolf.persistentVolumeClaim.new({
    name: configPvcName,
    namespace: vars.databases.namespace,
    storage: "2Gi"
  }),

  // Config map containing config file
  // configMap.new(configMapName) +
  // configMap.metadata.withNamespace(vars.databases.namespace) +
  // configMap.withData({
  //   "config.cnf": |||
  //     [mariadb]
  //     ssl_cert = /certs/tls.crt
  //     ssl_key = /certs/tls.key
  //     # Not required by default because vault doesn't support it.
  //     # https://github.com/hashicorp/vault/issues/6444
  //     # require_secure_transport = on
  //   |||
  // })

  // Service
  service.new(serviceName, {
    "app.kubernetes.io/name": vars.databases.mariadb.appName,
  }, [
    servicePort.newNamed(vars.databases.mariadb.port.name, vars.databases.mariadb.port.number, vars.databases.mariadb.port.number)
  ]) +
  service.metadata.withNamespace(vars.databases.namespace) +
  service.spec.withType("LoadBalancer") +
  service.spec.withLoadBalancerIP(
    if mode == "test"
    then vars.databases.mariadb.testLoadBalancerIP
    else vars.databases.mariadb.loadBalancerIP),

  // Stateful set
  statefulSet.metadata.withNamespace(vars.databases.namespace) +
  statefulSet.new("mariadb", replicas=1, containers=[
    container.new("mariadb", "mariadb:10.10") +
    container.resources.withRequests({
      cpu: if mode == "test" then "50m" else "250m"
    }) +
    container.withPorts([
      containerPort.newNamed(vars.databases.mariadb.port.number, vars.databases.mariadb.port.name)
    ]) +
    container.withEnvMixin([
      // ALTER USER 'root'@'%' IDENTIFIED BY 'newpasswordhere';
      envVar.new("MARIADB_ROOT_PASSWORD", vars.databases.mariadb.initialPassword),
    ]) +
    container.withVolumeMounts([
      volumeMount.new(configPvcName, "/var/lib/mysql"),
      volumeMount.new(configMapName, "/etc/mysql/conf.d"),
      volumeMount.new(certsVolumeName, "/certs")
    ])
  ]) +
  statefulSet.spec.selector.withMatchLabels({
    "app.kubernetes.io/name": vars.databases.mariadb.appName,
  }) +
  statefulSet.spec.template.metadata.withLabels({
    "app.kubernetes.io/name": vars.databases.mariadb.appName,
  }) +
  statefulSet.spec.template.spec.withVolumes([
    volume.fromPersistentVolumeClaim(configPvcName, configPvcName),
    volume.fromConfigMap(configMapName, configMapName),
    volume.fromSecret(certsVolumeName, vars.cluster.wildcard_cert_secret),
  ]) +
  statefulSet.spec.withServiceName(serviceName),
]
