param region string
param environment string
param location string = resourceGroup().location
param vNetAddressPrefix string
param privateEndpointSubnetAddressPrefix string


module names 'resource-names.bicep' = {
  name: 'resource-names'
  params: {
    region: region
    environment: environment
  }
}


var storageAccountPrivateDnsZoneName = 'privatelink.blob.${az.environment().suffixes.storage}'
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var monitorPrivateDnsZoneName = 'privatelink.monitor.azure.com'
var omsPrivateDnsZoneName = 'privatelink.oms.opinsights.azure.com'
var odsPrivateDnsZoneName = 'privatelink.ods.opinsights.azure.com'
var agentSvcPrivateDnsZoneName = 'privatelink.agentsvc.azure-automation.net'

var privateDnsZoneNames = [
  keyVaultPrivateDnsZoneName
  monitorPrivateDnsZoneName
  omsPrivateDnsZoneName
  odsPrivateDnsZoneName
  agentSvcPrivateDnsZoneName
  storageAccountPrivateDnsZoneName
]

module dnsDeployment 'dns.bicep' = [for privateDnsZoneName in privateDnsZoneNames: {
  name: 'dns-deployment-${privateDnsZoneName}'
  scope: resourceGroup()
  params: {
    privateDnsZoneName: privateDnsZoneName
  }
}]

module loggingDeployment 'logging.bicep' = {
  name: 'logging-deployment'
  dependsOn: [
    dnsDeployment
  ]
  params: {
    appInsightsName: names.outputs.appInsightsName
    privateLinkScopePrivateEndpointName: names.outputs.privateLinkScopePrivateEndpointName
    logAnalyticsWorkspaceName: names.outputs.logAnalyticsWorkspaceName
    location: location
    privateEndpointSubnetName: vNetDeployment.outputs.privateEndpointSubnetName
    vNetName: vNetDeployment.outputs.vNetName
  }
}

module managedIdentityDeployment 'managed-identity.bicep' = {
  name: 'managed-identity-deployment'
  params: {
    location: location
    managedIdentityName: names.outputs.managedIdentityName
  }
}

module vNetDeployment 'vnet.bicep' = {
  name: 'vnet-deployment'
  params: {
    location: location
    privateEndpointSubnetNetworkSecurityGroupName: names.outputs.privateEndpointSubnetNetworkSecurityGroupName
    privateEndpointSubnetAddressPrefix: privateEndpointSubnetAddressPrefix
    privateEndpointSubnetName: names.outputs.privateEndpointSubnetName
    vNetAddressPrefix: vNetAddressPrefix
    vNetName: names.outputs.vNetName
    privateDnsZoneNames: privateDnsZoneNames
  }
}

module keyVaultDeployment 'key-vault.bicep' = {
  name: 'key-vault-deployment'
  params: {
    keyVaultName: names.outputs.keyVaultName
    keyVaultPrivateEndpointName: names.outputs.keyVaultPrivateEndpointName
    vNetName: vNetDeployment.outputs.vNetName
    privateEndpointSubnetName: vNetDeployment.outputs.privateEndpointSubnetName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    location: location
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
    keyVaultDnsZoneName: keyVaultPrivateDnsZoneName
  }
}

