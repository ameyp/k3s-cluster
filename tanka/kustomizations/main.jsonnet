local infra_controllers = import "./infra-controllers.libsonnet";
local infra_configs = import "./infra-configs.libsonnet";
local infra_traefik = import "./infra-traefik.libsonnet";
local infra_vault = import "./infra-vault.libsonnet";

function(mode)
  infra_controllers(mode) +
  infra_configs(mode) +
  infra_traefik(mode) +
  infra_vault(mode)
