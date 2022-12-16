{
  cluster: {
    controller_ip: '192.168.1.201',
  },
  argo: {
    namespace: 'argocd',
    project: 'wirywolf',
  },
  longhorn: {
    namespace: 'longhorn-system',
  },
  monitoring: {
    namespace: 'monitoring',
    prometheus_stack_name: 'prometheus-stack'
  },
  vault: {
    namespace: 'vault',
    address: 'https://vault.wirywolf.com',
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
    test_ip_block: '192.168.201.0/28',
  },
  traefik: {
    namespace: 'traefik',
    load_balancer_ip: '192.168.80.10',
    test_load_balancer_ip: '192.168.201.10',
  },
}
