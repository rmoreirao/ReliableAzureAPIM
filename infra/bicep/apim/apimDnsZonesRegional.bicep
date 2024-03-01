import {networkingResourcesType, sharedResourcesType, apimRegionalSettingsType} from '../bicepParamTypes.bicep'

param vnetId                  string
param apimName                  string
param apimPrivateIPAddress      string
param apimGatewayDnsZoneName string
param apimDeveloperDnsZoneName string
param apimManagementDnsZoneName string

resource gatewayRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${apimGatewayDnsZoneName}/${apimName}'
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
  name: '${apimDeveloperDnsZoneName}/${apimName}'
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
  name: '${apimManagementDnsZoneName}/${apimName}'
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
  name: '${apimGatewayDnsZoneName}/gateway-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource developerVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${apimDeveloperDnsZoneName}/developer-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource managementVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${apimManagementDnsZoneName}/management-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}
