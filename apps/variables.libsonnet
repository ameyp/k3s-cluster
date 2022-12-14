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
}
