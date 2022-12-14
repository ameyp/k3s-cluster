local infra_controllers = import "./infra-controllers.libsonnet";
local infra_configs = import "./infra-configs.libsonnet";
local infra_traefik = import "./infra-traefik.libsonnet";
local infra_databases = import "./infra-databases.libsonnet";
local infra_vault = import "./infra-vault.libsonnet";
local infra_vault_config_operator = import "./infra-vault-config-operator.libsonnet";
local infra_vault_data = import "./infra-vault-data.libsonnet";

function(mode)
  infra_controllers(mode) +
  infra_configs(mode) +
  infra_traefik(mode) +
  infra_databases(mode) +
  infra_vault(mode) +
  infra_vault_config_operator(mode) +
  infra_vault_data(mode)
