local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';

function(mode) {
  "configs/serving-cert.yaml": {
    apiVersion: "cert-manager.io/v1",
    kind: "Certificate",
    metadata: {
      # https://github.com/redhat-cop/vault-config-operator/blob/b6ba1ca04bf52ee3dd2245454598246b230981c0/config/default/kustomization.yaml#L65
      # https://github.com/redhat-cop/vault-config-operator/blob/3077a7f1694483ece6032a8c54b51827237401ab/config/helmchart/kustomization.yaml#L13
      name: "serving-cert",
      namespace: vars.vault.namespace,
    },
    spec: {
      dnsNames: [
        "vault-config-operator-webhook-service.%s.svc" % vars.vault.namespace,
        "vault-config-operator-webhook-service.%s.svc.cluster.local" % vars.vault.namespace,
      ],
      issuerRef: {
        name: vars.cert_manager.self_signed_issuer,
        kind: "ClusterIssuer",
      },
      secretName: "webhook-server-cert",
    },
  },
  "configs/metrics-cert.yaml": {
    apiVersion: "cert-manager.io/v1",
    kind: "Certificate",
    metadata: {
      name: "vault-config-operator-metrics",
      namespace: vars.vault.namespace,
    },
    spec: {
      dnsNames: [
        "vault-config-operator-controller-manager-metrics-service.%s.svc" % vars.vault.namespace,
        "vault-config-operator-controller-manager-metrics-service.%s.svc.cluster.local" % vars.vault.namespace,
      ],
      issuerRef: {
        name: vars.cert_manager.self_signed_issuer,
        kind: "ClusterIssuer",
      },
      secretName: "vault-config-operator-certs",
    },
  },
}
