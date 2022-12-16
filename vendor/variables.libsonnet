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
  traefik: {
    namespace: 'traefik',
    load_balancer_ip: '192.168.80.10',
  }
}
