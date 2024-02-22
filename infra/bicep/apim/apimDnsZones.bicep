param vnetName                  string
param vnetRG                    string
param apimName                  string
param apimPrivateIPAddress      string

/*
Createa a Private DNS ZOne, A Record and Vnet Link for each of the below endpoints

API Gateway	                {APIM Name}.azure-api.net
The new developer portal	  {APIM Name}.developer.azure-api.net
Direct management endpoint	{APIM Name}.management.azure-api.net

*/

/*
 Retrieve APIM and Virtual Network
*/

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

// DNS Zones

resource gatewayDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

resource developerDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'developer.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

resource managementDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'management.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

resource gatewayRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: gatewayDnsZone
  name: apimName
  properties: {
    aRecords: [
      {
        ipv4Address: apimPrivateIPAddress
      }
    ]
    ttl: 36000
  }
}

resource developerRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: developerDnsZone
  name: apimName
  properties: {
    aRecords: [
      {
        ipv4Address: apimPrivateIPAddress
      }
    ]
    ttl: 36000
  }
}

resource managementRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: managementDnsZone
  name: apimName
  properties: {
    aRecords: [
      {
        ipv4Address: apimPrivateIPAddress
      }
    ]
    ttl: 36000
  }
}

resource gatewayVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: gatewayDnsZone
  name: 'gateway-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource developerVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: developerDnsZone
  name: 'gateway-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource managementVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: managementDnsZone
  name: 'gateway-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}
