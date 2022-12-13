local vars = import 'variables.libsonnet';

local mode = std.extVar('mode');

function(mode='test') {
  apiVersion: "argoproj.io/v1alpha1",
  kind: "Application",
  metadata: {
    name: "longhorn",
    namespace: vars.argo.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '1',
    },
  },
  spec: {
    project: vars.argo.project,
    source: {
      repoURL: 'https://charts.longhorn.io',
      targetRevision: '1.3.2',
      chart: 'longhorn',
      helm: {
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
        }),
      },
    },
    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: vars.longhorn.namespace,
    },
    syncPolicy: {
      automated: {
        selfHeal: true,
      },
      syncOptions: [
        'Validate=false',
        'CreateNamespace=true',
      ],
      retry: {
        limit: 2,
        backoff: {
          duration: '5s',
          factor: 2,
          maxDuration: '3m',
        },
      },
    },
  },
}
