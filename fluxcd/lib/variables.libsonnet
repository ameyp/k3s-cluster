{
  cluster: {
    test_controller_ip: '192.168.1.201',
    controller_ip: '192.168.80.81',
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
    singleReplicaStorageClass: 'longhorn-single',
    defaultStorageClass: "longhorn",
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
      loadBalancerIP: '192.168.80.2',
      testLoadBalancerIP: '192.168.1.208',
    },
    main: {
      ingress: {
        subdomain: 'vault',
        port: 8300,
      },
      internalCertSecret: 'vault-internal-tls-secret',
      configFilePath: '/vault/secrets/server-config',
      loadBalancerIP: '192.168.80.3',
      testLoadBalancerIP: '192.168.1.209',
    },
  },
  kured: {
    namespace: 'kured'
  },
  databases: {
    namespace: "databases",
    postgresql: {
      subdomain: "postgresql",
      loadBalancerIP: "192.168.80.11",
      testLoadBalancerIP: "192.168.1.211",
      initialPasswordSecret: "postgresql-initial-password",
      initialPassword: "postgrespassword",
      port: {
        name: "tcp",
        number: 5432,
      }
    },
    mariadb: {
      subdomain: "mariadb",
      appName: "mariadb",
      loadBalancerIP: "192.168.80.14",
      testLoadBalancerIP: "192.168.1.214",
      initialPassword: "mariadbrootpassword",
      port: {
        name: "tcp",
        number: 3306
      },
    }
  },
  firefly: {
    namespace: "firefly",
  },
  gitea: {
    namespace: "gitea",
  },
  immich: {
    namespace: "immich",
  },
}
