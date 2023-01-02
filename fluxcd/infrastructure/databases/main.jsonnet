local vars = import "variables.libsonnet";
local kustomizations = import "./kustomizations.libsonnet";
local prereqs = import "./prereqs.libsonnet";
local mariadb = import "./mariadb.libsonnet";
local postgresql = import "./postgresql.libsonnet";

function(mode)
  kustomizations(mode) +
  prereqs(mode) +
  mariadb(mode) +
  postgresql(mode)
