local policies = import "./policies.libsonnet";
local kubernetes_roles = import "./kubernetes_roles.libsonnet";

function(mode)
  policies(mode) +
  kubernetes_roles(mode)
