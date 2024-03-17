import { apimRegionalSettingsType} from '../bicepParamTypes.bicep'

param vnetId                  string
param apimName                  string
param apimPrivateIPAddress      string
param apimGatewayDnsZoneName string
param apimGatewayRegionalUrl string

param apimDeveloperDnsZoneName string
param apimDevPortalRegionalUrl string?

param apimManagementDnsZoneName string
param apimManagementRegionalUrl string?

// There's a specific logic to create the Api Gateway DNS entries
// Here we are pointing only to the regional URLs
// APIM Name = apim-multi-dihk
// Sample gatewayRegionalUrl of main region: 'https://apim-multi-dihk-westeurope-01.regional.azure-api.net'
// Sample other regions: 'https://apim-multi-dihk-germanywestcentral-01.regional.azure-api.net'
// apimGatewayDnsEntryName = remove the 'https://' and '.azure-api.net' from apimGatewayRegionalUrl

var apimGatewayDnsEntryName = replace(replace(apimGatewayRegionalUrl,'https://', ''),'.azure-api.net', '')

resource gatewayDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: apimGatewayDnsZoneName
}

resource gatewayRegionalRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: gatewayDnsZone
  name: apimGatewayDnsEntryName
  properties: {
    aRecords: [
      {
        ipv4Address: apimPrivateIPAddress
      }
    ]
    ttl: 36000
  }
}

// Create a record on the DNS zone for the Load Balancer Api Gateway Endpoint
// The endpoint is: 'https://{apim name}.azure-api.net'
// This is created only on the Main region - when both devportal and management regional URLs are not provided
resource gatewayMainRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (apimDevPortalRegionalUrl == null && apimDevPortalRegionalUrl == null )  {
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


resource gatewayVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: gatewayDnsZone
  name: uniqueString(vnetId, apimGatewayDnsEntryName)
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource developerRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (apimDevPortalRegionalUrl != null) {
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


resource developerVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (apimDevPortalRegionalUrl != null) {
  name: '${apimDeveloperDnsZoneName}/developer-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource managementVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (apimManagementRegionalUrl != null) {
  name: '${apimManagementDnsZoneName}/management-vnet-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource managementRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (apimManagementRegionalUrl != null) {
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

output apimGatewayDnsEntryName string = apimGatewayDnsEntryName
output name string = '${apimGatewayDnsZoneName}/${apimGatewayDnsEntryName}'
