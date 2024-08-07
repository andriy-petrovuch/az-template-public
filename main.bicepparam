using './main.bicep'

param location = 'centralus'
param tags = {
  DeploymentMethod : 'IaC'}
param resourcePrefix = 'test'
param vNetAddressSpace = '172.20.128.0/20'
param deployNvaFirewall = 'yes'

