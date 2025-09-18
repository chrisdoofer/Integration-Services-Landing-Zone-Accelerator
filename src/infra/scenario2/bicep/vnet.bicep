param vNetName string
param vNetAddressPrefix string
param privateEndpointSubnetName string
param privateEndpointSubnetAddressPrefix string
param privateEndpointSubnetNetworkSecurityGroupName string
param location string
param privateDnsZoneNames array

resource vNet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointSubnetAddressPrefix
          networkSecurityGroup: {
            id: privateEndpointNetworkSecurityGroup.id
          }
        }
      }
    ]
  }
}     

resource privateEndpointNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: privateEndpointSubnetNetworkSecurityGroupName
  location: location
  properties: {
    securityRules: []
  }
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for privateDnsZoneName in privateDnsZoneNames: {
  name: '${privateDnsZoneName}/privateDnsZoneLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vNet.id
    }
    registrationEnabled: false
  }
}]

output vNetName string = vNet.name
output privateEndpointSubnetName string = privateEndpointSubnetName
