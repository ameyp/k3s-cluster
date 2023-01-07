local configuration = import "./configuration.libsonnet";
local kustomizations = import "./kustomizations.libsonnet";
local release = import "./release.libsonnet";

function(mode)
  kustomizations(mode) +
  configuration(mode) +
  release(mode)

