
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
param location string
param vnetName string
param vnetRG string
param storageInboundSubnetId string

var storageAccountName  = toLower(take(replace('stbbackend${workloadName}${environment}${location}', '-',''), 24))

var storageAccountSku  = 'Standard_LRS'
var storageAccountKind  = 'StorageV2'

var storageAccounts_minTLSVersion = 'TLS1_2'

var privateEndpointStorageAccountQueueName = 'pep-queue-${workloadName}-${environment}-${location}'
var privateEndpointStorageaccountBlobName = 'pep-blob-${workloadName}-${environment}-${location}'
var privateEndpointStorageAccountFileName = 'pep-file-${workloadName}-${environment}-${location}'
var privateEndpointStorageAccountTableName = 'pep-table-${workloadName}-${environment}-${location}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  properties: {
    minimumTlsVersion: storageAccounts_minTLSVersion
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}


module queueStoragePrivateEndpoint './backendStorageNetworking.bicep' = {
  name: privateEndpointStorageAccountQueueName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageAccountQueueName
    storageAcountName: storageAccountName
    groupId: 'queue'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: storageInboundSubnetId
  }
}

module blobStoragePrivateEndpoint './backendStorageNetworking.bicep' = {
  name: privateEndpointStorageaccountBlobName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageaccountBlobName
    storageAcountName: storageAccountName
    groupId: 'blob'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: storageInboundSubnetId
  }
}

module tableStoragePrivateEndpoint './backendStorageNetworking.bicep' = {
  name: privateEndpointStorageAccountTableName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageAccountTableName
    storageAcountName: storageAccountName
    groupId: 'table'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: storageInboundSubnetId
  }
}

module fileStoragePrivateEndpoint './backendStorageNetworking.bicep' = {
  name: privateEndpointStorageAccountFileName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageAccountFileName
    storageAcountName: storageAccountName
    groupId: 'file'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: storageInboundSubnetId
  }
}

output storageAccountName string = storageAccountName
