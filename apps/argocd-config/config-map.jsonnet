local vars = import 'variables.libsonnet';

{
  apiVersion: "v1",
  kind: "ConfigMap",
  metadata: {
    name: "argocd-cm",
    namespace: vars.argo.namespace,
  },
  labels: {
    "app.kubernetes.io/name": "argocd-cm",
    "app.kubernetes.io/part-of": "argocd"
  },
  data: {
    "resource.customizations": |||
      argoproj.io/Application:
        health.lua: |
          hs = {}
          hs.status = "Progressing"
          hs.message = ""
          if obj.status ~= nil then
            if obj.status.health ~= nil then
              hs.status = obj.status.health.status
              if obj.status.health.message ~= nil then
                hs.message = obj.status.health.message
              end
            end
          end
          return hs
    |||,
    "application.instanceLabelKey": "argocd.wirywolf.com/appname"
  }
}
