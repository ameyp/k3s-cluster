local agent_autounseal_configmap = import './agent-autounseal.libsonnet';
local main_ingress = import './main-ingress.libsonnet';
local unsealer_ingress = import './unsealer-ingress.libsonnet';

function(mode='test')
  agent_autounseal_configmap(mode)
