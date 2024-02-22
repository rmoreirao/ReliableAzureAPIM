targetScope='resourceGroup'
@description('Standardized suffix text to be added to resource names')
param resourceSuffix string

@description('Azure location to which the resources are to be deployed')
param location string

param vnetName string
param vnetRG string
param keyVaultPrivateEndpointSubnetid string

var keyvaultPrivateEndpointName   = 'pep-kv-${resourceSuffix}'

// Variables - ensure key vault name does not end with '-'
// var tempKeyVaultName = take('ke-${resourceSuffix}', 24) // Must be between 3-24 alphanumeric characters 
// var keyVaultNameExternal = endsWith(tempKeyVaultName, '-') ? substring(tempKeyVaultName, 0, length(tempKeyVaultName) - 1) : tempKeyVaultName

var tempKeyVaultNameInternal = take('ki-${resourceSuffix}', 24) // Must be between 3-24 alphanumeric characters 
var keyVaultNameInternal = endsWith(tempKeyVaultNameInternal, '-') ? substring(tempKeyVaultNameInternal, 0, length(tempKeyVaultNameInternal) - 1) : tempKeyVaultNameInternal

// resource keyVaultExternal 'Microsoft.KeyVault/vaults@2019-09-01' = {
//   name: keyVaultNameExternal
//   location: location
//   properties: {
//     tenantId: subscription().tenantId
//     sku: {
//       family: 'A'
//       name: 'standard'
//     }    
//     accessPolicies: [
//     ]
//   }
// }

// resource keyVaultInternal 'Microsoft.KeyVault/vaults@2021-10-01' = {
//   name: keyVaultNameInternal
//   location: location
//   properties: {
//     enableRbacAuthorization: true
//     publicNetworkAccess: 'Disabled'
//     tenantId: tenant().tenantId
//     sku: {
//       family: 'A'
//       name: 'standard'
//     }
//     networkAcls: {
//       bypass: 'AzureServices'
//       defaultAction: 'Deny'
//       ipRules: []
//       virtualNetworkRules: []
//     }
//   }
// }

// var privateDNSZoneName = 'privatelink.vaultcore.azure.net'

// resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
//   name: vnetName
//   scope: resourceGroup(vnetRG)
// }


// resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
//   name: privateDNSZoneName
//   location: 'global'
// }

// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
//   parent: keyVaultPrivateDnsZone
//   name: uniqueString(vnet.id)
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

// resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
//   name: keyvaultPrivateEndpointName
//   location: location
//   properties: {
//     subnet: {
//       id: keyVaultPrivateEndpointSubnetid
//     }
//     privateLinkServiceConnections: [
//       {
//         name: keyvaultPrivateEndpointName
//         properties: {
//           privateLinkServiceId: keyVaultInternal.id
//           groupIds: [
//             'vault'
//           ]
//         }
//       }
//     ]
//   }
// }

// resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
//   parent: privateEndpoint
//   name: 'default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: '${keyVaultNameInternal}-vaultcore-windows-net'
//         properties: {
//           privateDnsZoneId: keyVaultPrivateDnsZone.id
//         }
//       }
//     ]
//   }
// }

output keyVaultName string = keyVaultNameInternal
