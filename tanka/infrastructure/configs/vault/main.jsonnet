local initializer_rbac = import './initializer-rbac.libsonnet';
local main_initializer = import './main-initializer.libsonnet';
local unseal_initializer = import './unsealer-initializer.libsonnet';

local agent_autounseal_configmap = import './agent-autounseal.libsonnet';
local main_ingress = import './main-ingress.libsonnet';
local unsealer_ingress = import './unsealer-ingress.libsonnet';

function(mode='test')
  initializer_rbac(mode) +
  main_initializer(mode) +
  unseal_initializer(mode) +
  agent_autounseal_configmap(mode) +
  main_ingress(mode) +
  unsealer_ingress(mode)
