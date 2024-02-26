@description('A short name for the workload being deployed alphanumberic only')
@maxLength(8)
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('Azure location to which the resources are to be deployed')
param location string

param vnetId string
param keyVaultPrivateEndpointSubnetid string
var resourceSuffix = '${workloadName}-${environment}-${location}-001'

var keyvaultPrivateEndpointName   = 'pep-kv-${resourceSuffix}'

var tempKeyVaultNameInternal = take('ki-${resourceSuffix}', 24) // Must be between 3-24 alphanumeric characters 
var keyVaultNameInternal = endsWith(tempKeyVaultNameInternal, '-') ? substring(tempKeyVaultNameInternal, 0, length(tempKeyVaultNameInternal) - 1) : tempKeyVaultNameInternal

resource keyVaultInternal 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultNameInternal
  location: location
  properties: {
    enableRbacAuthorization: true
    publicNetworkAccess: 'Disabled'
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

var privateDNSZoneName = 'privatelink.vaultcore.azure.net'


resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: keyVaultPrivateDnsZone
  name: uniqueString(vnetId)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: keyvaultPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: keyVaultPrivateEndpointSubnetid
    }
    privateLinkServiceConnections: [
      {
        name: keyvaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVaultInternal.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${keyVaultNameInternal}-vaultcore-windows-net'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}

output keyVaultName string = keyVaultNameInternal
