{
  cluster: {
    controller_ip: '192.168.1.201',
    domain_name: 'wirywolf.com',
    test_domain_prefix: 'test',
    wildcard_cert_secret: 'wildcard-tls-secret',
  },
  argo: {
    namespace: 'argocd',
    project: 'wirywolf',
    tls_secret_name: 'argocd-server-tls',
    ingress: {
      subdomain: 'argocd',
      port: 443,
    }
  },
  longhorn: {
    namespace: 'longhorn-system',
  },
  monitoring: {
    namespace: 'monitoring',
    prometheus_stack_name: 'prometheus-stack'
  },
  kubernetes_reflector: {
    namespace: 'kubernetes-reflector',
  },
  cert_manager: {
    namespace: 'cert-manager',
    lets_encrypt_issuer: 'letsencrypt',
    self_signed_issuer: 'selfsigned',
  },
  metallb: {
    namespace: 'metallb-system',
    pool_name: 'external',
    ip_block: '192.168.80.0/28',
    test_ip_block: '192.168.1.210/28', // 192.168.1.208 - 192.168.1.223
  },
  traefik: {
    namespace: 'traefik',
    load_balancer_ip: '192.168.80.10',
    test_load_balancer_ip: '192.168.1.210',
  },
  vault_unsealer: {
    namespace: 'vault',
    ingress: {
      subdomain: 'vault-unsealer',
      port: 8200,
    },
  },
  vault: {
    namespace: 'vault',
    ingress: {
      subdomain: 'vault',
      port: 8300,
    },
    testReplicas: 1,
    prodReplicas: 3,
    internalCertSecret: 'vault-internal',
  },
}
