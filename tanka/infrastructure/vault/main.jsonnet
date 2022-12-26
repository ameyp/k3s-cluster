local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';
local repo = import './hashicorp-chart.libsonnet';
local unsealer = import './unsealer.libsonnet';
local vault = import './vault.libsonnet';

function(mode='test') [repo(mode), unsealer(mode), vault(mode)]
