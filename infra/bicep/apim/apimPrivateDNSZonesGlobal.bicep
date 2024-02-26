// These are Global resources, should only be deployed one
// import {privateDNSZoneResourcesType} from '../bicepParamTypes.bicep'

// var keyVaultPrivateDNSZoneName = 'privatelink.vaultcore.azure.net'


// resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
//   name: keyVaultPrivateDNSZoneName
//   location: 'global'
// }

var gatewayDnsZoneName = 'azure-api.net'

resource gatewayDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: gatewayDnsZoneName
  location: 'global'
  properties: {}
}

var developerDnsZoneName = 'developer.azure-api.net'

resource developerDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: developerDnsZoneName
  location: 'global'
  properties: {}
}

var managementDnsZoneName = 'management.azure-api.net'
resource managementDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: managementDnsZoneName
  location: 'global'
  properties: {}
}

output apimDeveloperDnsZoneName string = developerDnsZone.name
output apimGatewayDnsZoneName string =  gatewayDnsZone.name
output apimManagementDnsZoneName string =  managementDnsZone.name

