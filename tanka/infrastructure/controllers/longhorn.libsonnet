local vars = import 'variables.libsonnet';

function(mode='test') [{
  apiVersion: "source.toolkit.fluxcd.io/v1beta2",
  kind: "HelmRepository",
  metadata: {
    name: "longhorn",
    namespace: vars.flux.namespace,
  },
  spec: {
    interval: "24h",
    url: "https://charts.longhorn.io"
  }
}, {

  apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
  kind: "HelmRelease",
  metadata: {
    name: "longhorn",
    namespace: vars.flux.namespace,
  },
  spec: {
    targetNamespace: vars.longhorn.namespace,
    interval: "30m",
    install: {
      createNamespace: true,
    },
    releaseName: "longhorn",
    chart: {
      spec: {
        chart: "longhorn",
        version: "1.3.2",
        sourceRef: {
          kind: "HelmRepository",
          name: "longhorn",
          namespace: vars.flux.namespace,
        },
        interval: "12h",
      },
    },
    values: {
      values: std.manifestYamlDoc({
        persistence: {
          defaultClass: false,
          defaultClassReplicaCount: if mode == 'test' then 1 else 3,
          reclaimPolicy: 'Delete',
        },
        defaultSettings: {
          defaultReplicaCount: if mode == 'test' then 1 else 3,
          nodeDownPodDeletionPolicy: 'delete-both-statefulset-and-deployment-pod',
          backupTarget: 's3://amey-backups-longhorn@us-west-004/',
          backupTargetCredentialSecret: 'longhorn-backup-secret',
        },
        longhornManager: {
          tolerations: [{
            key: 'node-role.kubernetes.io/master',
            operator: 'Equal',
            value: 'true',
          }],
          effect: 'NoSchedule'
        },
        longhornDriver: {
          tolerations: [{
            key: 'node-role.kubernetes.io/master',
            operator: 'Equal',
            value: 'true',
          }],
          effect: 'NoSchedule',
        },
        longhornUI: {
          tolerations: [{
            key: 'node-role.kubernetes.io/master',
            operator: 'Equal'
          }],
          value: 'true',
        },
        effect: 'NoSchedule',
      })
    },
  },
}]
