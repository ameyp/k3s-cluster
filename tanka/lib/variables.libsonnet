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
  flux: {
    namespace: 'flux-system'
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
    loadBalancerIP: '192.168.80.10',
    testLoadBalancerIP: '192.168.1.210',
  },
  vault: {
    namespace: 'vault',
    initializer: {
      service_account: 'vault-init',
    },
    unsealer: {
      ingress: {
        subdomain: 'vault-unsealer',
        port: 8200,
      },
    },
    main: {
      ingress: {
        subdomain: 'vault',
        port: 8300,
      },
      internalCertSecret: 'vault-internal-tls-secret',
      configFilePath: '/vault/secrets/server-config',
    },
  },
}
