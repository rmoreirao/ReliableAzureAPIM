
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
param storageInboundSubnetId string
param vnetId string

param storageQueuePrivateDNSZoneName string
param storageQueuePrivateDnsZoneId string
param storageBlobPrivateDNSZoneName string
param storageBlobPrivateDnsZoneId string
param storageTablePrivateDNSZoneName string
param storageTablePrivateDnsZoneId string
param storageFilePrivateDNSZoneName string
param storageFilePrivateDnsZoneId string

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
    vnetId: vnetId
    subnetId: storageInboundSubnetId
    privateDnsZoneId: storageQueuePrivateDnsZoneId
    privateDnsZoneName: storageQueuePrivateDNSZoneName
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
    vnetId: vnetId
    subnetId: storageInboundSubnetId
    privateDnsZoneId: storageBlobPrivateDnsZoneId
    privateDnsZoneName: storageBlobPrivateDNSZoneName
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
    vnetId: vnetId
    subnetId: storageInboundSubnetId
    privateDnsZoneId: storageTablePrivateDnsZoneId
    privateDnsZoneName: storageTablePrivateDNSZoneName
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
    vnetId: vnetId
    subnetId: storageInboundSubnetId
    privateDnsZoneId: storageFilePrivateDnsZoneId
    privateDnsZoneName: storageFilePrivateDNSZoneName
  }
}

output storageAccountName string = storageAccountName
