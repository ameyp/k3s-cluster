local initializer_rbac = import './initializer-rbac.libsonnet';
local main_initializer = import './main-initializer.libsonnet';
local unseal_initializer = import './unsealer-initializer.libsonnet';

function(mode='test')
  initializer_rbac(mode) +
  main_initializer(mode) +
  unseal_initializer(mode)
