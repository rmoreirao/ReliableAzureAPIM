param vnetId string
param backendPrivateDNSZoneName string

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${backendPrivateDNSZoneName}/${uniqueString(vnetId)}' 
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}
