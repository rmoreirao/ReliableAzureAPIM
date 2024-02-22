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
param vnetRGName string
param apimVNetName string

param logicAppsStorageInboundSubnetid string
param functionsOutboundSubnetid string
param functionsInboundSubnetid string
param logicAppsOutboundSubnetid string
param logicAppsInboundSubnetid string


module backendStorage './backendStorage.bicep' = {
  name: 'backendstorageresources'
  scope: resourceGroup(backendRGName)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    vnetName: apimVNetName
    vnetRG: vnetRGName
    storageInboundSubnetId: logicAppsStorageInboundSubnetid
  }
}

module backendPrivateDns './backendPrivateDns.bicep' = {
  name: 'backendresourcesprivatedns'
  scope: resourceGroup(backendRGName)
  params: {
    vnetName: apimVNetName
    vnetRG: vnetRGName
  }
}

module backendFunctions './backendFunctions.bicep' = {
  name: 'backendresourcesfunctions'
  scope: resourceGroup(backendRGName)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    functiounsOutboundSubnetId: functionsOutboundSubnetid
    functionsInboundPrivateEndpointSubnetid: functionsInboundSubnetid
    storageAccountName: backendStorage.outputs.storageAccountName
    backendPrivateDnsZoneId: backendPrivateDns.outputs.backendPrivateDnsZoneId
  }
}

module backendLogicApps './backendLogicApps.bicep' = {
  name: 'backendresourceslogicapps'
  scope: resourceGroup(backendRGName)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    logicAppsOutboundSubnetId: logicAppsOutboundSubnetid
    logicAppsInboundPrivateEndpointSubnetid: logicAppsInboundSubnetid
    storageAccountName: backendStorage.outputs.storageAccountName
    backendPrivateDnsZoneId: backendPrivateDns.outputs.backendPrivateDnsZoneId
  }
}
