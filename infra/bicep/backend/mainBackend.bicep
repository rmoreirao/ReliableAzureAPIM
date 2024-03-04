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
param backendRGName string
param vnetId string

param backendPrivateDNSZoneName string
param backendPrivateDnsZoneId string

param logicAppsStorageInboundSubnetid string?
param functionsOutboundSubnetid string?
param functionsInboundSubnetid string?
param logicAppsOutboundSubnetid string?
param logicAppsInboundSubnetid string?

param storageQueuePrivateDNSZoneName string
param storageQueuePrivateDnsZoneId string
param storageBlobPrivateDNSZoneName string
param storageBlobPrivateDnsZoneId string
param storageTablePrivateDNSZoneName string
param storageTablePrivateDnsZoneId string
param storageFilePrivateDNSZoneName string
param storageFilePrivateDnsZoneId string

module backendStorage './backendStorage.bicep' = if (logicAppsStorageInboundSubnetid != null) {
  name: 'backendstorageresources'
  scope: resourceGroup(backendRGName)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    vnetId: vnetId
    storageInboundSubnetId: logicAppsStorageInboundSubnetid!
    storageBlobPrivateDnsZoneId: storageBlobPrivateDnsZoneId
    storageQueuePrivateDnsZoneId: storageQueuePrivateDnsZoneId
    storageTablePrivateDnsZoneId: storageTablePrivateDnsZoneId
    storageFilePrivateDnsZoneId: storageFilePrivateDnsZoneId
    storageBlobPrivateDNSZoneName: storageBlobPrivateDNSZoneName
    storageQueuePrivateDNSZoneName: storageQueuePrivateDNSZoneName
    storageTablePrivateDNSZoneName: storageTablePrivateDNSZoneName
    storageFilePrivateDNSZoneName: storageFilePrivateDNSZoneName
  }
}

module backendPrivateDns './backendPrivateDnsRegional.bicep' = if (functionsInboundSubnetid != null || logicAppsInboundSubnetid != null) {
  name: 'backendresourcesprivatedns'
  scope: resourceGroup(backendRGName)
  params: {
    backendPrivateDNSZoneName: backendPrivateDNSZoneName
    vnetId: vnetId
  }
}

module backendFunctions './backendFunctions.bicep' = if (functionsInboundSubnetid != null) {
  name: 'backendresourcesfunctions'
  scope: resourceGroup(backendRGName)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    functiounsOutboundSubnetId: functionsOutboundSubnetid!
    functionsInboundPrivateEndpointSubnetid: functionsInboundSubnetid!
    storageAccountName: backendStorage.outputs.storageAccountName
    backendPrivateDnsZoneId: backendPrivateDnsZoneId
  }
}

module backendLogicApps './backendLogicApps.bicep' = if (logicAppsInboundSubnetid != null) {
  name: 'backendresourceslogicapps'
  scope: resourceGroup(backendRGName)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    logicAppsOutboundSubnetId: logicAppsOutboundSubnetid!
    logicAppsInboundPrivateEndpointSubnetid: logicAppsInboundSubnetid!
    storageAccountName: backendStorage.outputs.storageAccountName
    backendPrivateDnsZoneId: backendPrivateDnsZoneId
  }
}
