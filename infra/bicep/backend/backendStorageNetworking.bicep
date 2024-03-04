param privateEndpointName string
param groupId string
param location string
param vnetId string
param subnetId string
param storageAccountId string
param storageAcountName string
param privateDnsZoneName string
param privateDnsZoneId string


// resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: domain
//   location: 'global'
// }

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZoneName}/${uniqueString(vnetId)}' 
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {      
        name: '${storageAcountName}-${groupId}-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId       
        }
      }
    ]
  }
  dependsOn: [
    vnetLink
  ]
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneGroupId string = dnsZoneGroup.id
output vnetLinksId string = vnetLink.id
