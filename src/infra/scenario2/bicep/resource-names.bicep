param region string
param environment string

output appInsightsName string = 'ai-${region}-${environment}'
output keyVaultName string = 'kv-${uniqueString(region, environment)}'
output keyVaultPrivateEndpointName string = 'kv-pe-${uniqueString(region, environment)}'
output logAnalyticsWorkspaceName string = 'la-${region}-${environment}'
output privateLinkScopePrivateEndpointName string = 'pls-pe-${region}-${environment}'
output managedIdentityName string = 'mi-${region}-${environment}'
output privateEndpointSubnetName string = 'private-endpoint-subnet'
output privateEndpointSubnetNetworkSecurityGroupName string = 'nsg-privateEndpoint-${region}-${environment}'
output vNetName string = 'vnet-${region}-${environment}'
