local longhorn = import "./longhorn.libsonnet";
local prometheus = import "./prometheus.libsonnet";
local kubernetes_reflector = import "./kubernetes-reflector.libsonnet";
local metallb = import "./metallb.libsonnet";
local cert_manager = import "./cert-manager.libsonnet";

function(mode='test')
  cert_manager(mode) +
  prometheus(mode) +
  longhorn(mode) +
  kubernetes_reflector(mode) +
  metallb(mode)
