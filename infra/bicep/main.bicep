targetScope='subscription'
import {vNetRegionalSettingsType, regionalSettingType, networkingResourcesType, sharedResourcesType, apimRegionalSettingsType, globalSettingsType} from 'bicepParamTypes.bicep'

// Parameters
@description('A short name for the workload being deployed alphanumberic only')
@maxLength(5)
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

param globalSettings globalSettingsType

param location string = deployment().location

param regionalSettings regionalSettingType[]

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var networkingResourceGroupName = 'rg-apim-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-apim-shared-${resourceSuffix}'
var backendResourceGroupName = 'rg-apim-backend-${resourceSuffix}'
var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}

module networkingModule './networking/mainNetworkingAllRegions.bicep' = {
  name: 'networkingresourcesallregions${workloadName}${environment}${location}'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    locationsSettings:regionalSettings
    firewallSku: globalSettings.firewallSettings.firewallSkuName
    firewallAvailabilityZones: globalSettings.firewallSettings.availabilityZones
  }
}

resource backendRG 'Microsoft.Resources/resourceGroups@2021-04-01' = if (globalSettings.?backendSettings != null) {
  name: backendResourceGroupName
  location: location
}

// module backendDns './backend/backendPrivateDnsGlobal.bicep' = if (globalSettings.?backendSettings != null) {
//   name: 'backendPrivateDnsGlobal${workloadName}${environment}${regionalSettings[0].location}'
//   scope: resourceGroup(backendRG.name)
// }

// Deoploy the Backend resources (Logic Apps & Functions) only to a Single Region
// // This can be adjusted to deploy to multiple regions in the future by adding a loop similar to the networking module
// module backend './backend/mainBackend.bicep' = if (globalSettings.?backendSettings != null) {
//   name: 'backendresources${workloadName}${environment}${regionalSettings[0].location}'
//   scope: resourceGroup(backendRG.name)
//   params: {
//     workloadName: workloadName
//     environment: environment
//     location: location    
//     backendRGName: backendRG.name
//     functionsInboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?functionsInboundSubnetid
//     functionsOutboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?functionsOutboundSubnetid
//     logicAppsInboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?logicAppsInboundSubnetid
//     logicAppsOutboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?logicAppsOutboundSubnetid
//     logicAppsStorageInboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?logicAppsStorageInboundSubnetid
//     vnetId: networkingModule.outputs.networkingResourcesArray[0].vnetId
//     backendPrivateDnsZoneId: backendDns.outputs.backendPrivateDnsZoneId
//     backendPrivateDNSZoneName: backendDns.outputs.backendPrivateDNSZoneName
//     storageBlobPrivateDnsZoneId: backendDns.outputs.storageBlobPrivateDnsZoneId
//     storageBlobPrivateDNSZoneName: backendDns.outputs.storageBlobPrivateDNSZoneName
//     storageFilePrivateDnsZoneId: backendDns.outputs.storageFilePrivateDnsZoneId
//     storageFilePrivateDNSZoneName: backendDns.outputs.storageFilePrivateDNSZoneName
//     storageQueuePrivateDnsZoneId: backendDns.outputs.storageQueuePrivateDnsZoneId
//     storageQueuePrivateDNSZoneName: backendDns.outputs.storageQueuePrivateDNSZoneName
//     storageTablePrivateDnsZoneId: backendDns.outputs.storageTablePrivateDnsZoneId
//     storageTablePrivateDNSZoneName: backendDns.outputs.storageTablePrivateDNSZoneName
//     storageSku: globalSettings.backendSettings!.storageSku!
//   }
// }

resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
  dependsOn: [
    networkingModule
  ]
}

module sharedPrivateDNSZone 'shared/sharedPrivateDNSZonesGlobal.bicep' = {
  name: 'sharedPrivateDnsZoneDeploy'
  scope: resourceGroup(sharedRG.name)
  params: {
  }
}

module shared './shared/mainShared.bicep' = [for (locationSetting,i) in regionalSettings: {
  name: 'sharedresources${workloadName}${environment}${locationSetting.location}'
  scope: resourceGroup(sharedRG.name)
  params: {
    devOpsAgentSubnetId: networkingModule.outputs.networkingResourcesArray[i].?devOpsAgentSubnetId
    environment: environment
    jumpboxSubnetId: networkingModule.outputs.networkingResourcesArray[i].?jumpBoxSubnetid
    resourceGroupName: sharedRG.name
    devOpsResourcesSettings: globalSettings.?devOpsAgentSettings
    jumpBoxResourcesSettings: globalSettings.?jumpBoxSettings
    workloadName: workloadName
    keyVaultPrivateEndpointSubnetid: networkingModule.outputs.networkingResourcesArray[i].?keyVaultPrivateEndpointSubnetid
    location: locationSetting.location
    vnetId: networkingModule.outputs.networkingResourcesArray[i].vnetId
    keyVaultPrivateDnsZoneName: sharedPrivateDNSZone.outputs.keyVaultPrivateDNSZoneName
    keyVaultPrivateDnsZoneId: sharedPrivateDNSZone.outputs.keyVaultPrivateDNSZoneId
  }
  dependsOn: [
    networkingModule
  ]
}]


resource apimRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apimResourceGroupName
  location: location
  dependsOn: [
    shared
  ]
}

module apimPrivateDNSZone 'apim/apimPrivateDNSZonesGlobal.bicep' = if (globalSettings.apimSettings != null) {
  name: 'apimPrivateDnsZoneDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
  }
}

module apimModule 'apim/apim.bicep'  = if (globalSettings.apimSettings != null) {
  name: 'apimDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
    resourceSuffix: resourceSuffix
    apimSubnetId: networkingModule.outputs.networkingResourcesArray[0].apimSubnetid
    appInsightsName: shared[0].outputs.resources.appInsightsName
    appInsightsId: shared[0].outputs.resources.appInsightsId
    appInsightsInstrumentationKey: shared[0].outputs.resources.appInsightsInstrumentationKey
    apimPublicIpId: networkingModule.outputs.networkingResourcesArray[0].apimPublicIpId
    publisherEmail: globalSettings.apimSettings.apimPublisherEmail
    publisherName: globalSettings.apimSettings.apimPublisherName
    skuName: globalSettings.apimSettings.apimSkuName
    keyVaultName: shared[0].outputs.resources.keyVaultName!
    keyVaultRG: sharedRG.name
    primaryRegionSettings: regionalSettings[0]
    additionalRegionSettings: skip(regionalSettings,1)
    additionalRegionsNetworkingResources: skip(networkingModule.outputs.networkingResourcesArray,1) 
  }
}



//Creation of private DNS zones for APIM
module dnsZoneModule 'apim/apimDnsZonesRegional.bicep'  =  [for (locationSetting,i) in regionalSettings: if (globalSettings.apimSettings != null){
  name: 'apimDnsZoneDeploy${workloadName}${environment}${locationSetting.location}${i}'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetId: networkingModule.outputs.networkingResourcesArray[i].vnetId
    apimName: apimModule.outputs.apimName
    // TO DO: to add the private IP addresses of APIM regions here!!!
    apimPrivateIPAddress: apimModule.outputs.apimPrivateIpAddress
    apimDeveloperDnsZoneName: apimPrivateDNSZone.outputs.apimDeveloperDnsZoneName
    apimManagementDnsZoneName: apimPrivateDNSZone.outputs.apimManagementDnsZoneName
    apimGatewayDnsZoneName: apimPrivateDNSZone.outputs.apimGatewayDnsZoneName
  }
}]


module appgwModule 'apim/appGateway.bicep' = if (globalSettings.appGatewaySettings != null) {
  name: 'appgwDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
    dnsZoneModule
  ]
  params: {
    resourceSuffix: resourceSuffix
    appGatewayFQDN: globalSettings.apimSettings.apimCustomDomainName
    location: location
    appGatewaySubnetId: networkingModule.outputs.networkingResourcesArray[0].appGatewaySubnetid
    keyVaultName: shared[0].outputs.resources.keyVaultName!
    keyVaultResourceGroupName: sharedRG.name
    appGatewayCertType: globalSettings.appGatewaySettings.apimAppGatewayCertType
    certPassword: globalSettings.appGatewaySettings.apimAppGatewayCertificatePassword
    logAnalyticsWorkspaceResourceId: shared[0].outputs.resources.logAnalyticsWorkspaceId
    deployScriptStorageSubnetId: networkingModule.outputs.networkingResourcesArray[0].deployScriptStorageSubnetId!
    environment: environment
    workloadName: workloadName
    appGatewayPublicIPAddressId: networkingModule.outputs.networkingResourcesArray[0].appGatewayPublicIpId
    apimName: apimModule.outputs.apimName
    apimCustomDomainName: globalSettings.apimSettings.apimCustomDomainName
    sku:globalSettings.appGatewaySettings.appGatewaySkuName
    minCapacity: globalSettings.appGatewaySettings.minCapacity
    maxCapacity: globalSettings.appGatewaySettings.maxCapacity
    zones: globalSettings.appGatewaySettings.?availabilityZones
  }
}

// This second deploy of APIM is required to add the custom domain name to the APIM instance
// Currently APIM can only access KeyVault via VNET integration using System Assigned Managed Identity
// So we need to deploy the APIM instance first to get the Managed Identity and then deploy the custom domain name
module apimModuleWithCustomDns 'apim/apim.bicep'  = if (globalSettings.apimSettings != null) {
  name: 'apimModuleWithCustomDns${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
    resourceSuffix: resourceSuffix
    apimSubnetId: networkingModule.outputs.networkingResourcesArray[0].apimSubnetid
    appInsightsName: shared[0].outputs.resources.appInsightsName
    appInsightsId: shared[0].outputs.resources.appInsightsId
    appInsightsInstrumentationKey: shared[0].outputs.resources.appInsightsInstrumentationKey
    apimPublicIpId: networkingModule.outputs.networkingResourcesArray[0].apimPublicIpId
    publisherEmail: globalSettings.apimSettings.apimPublisherEmail
    publisherName: globalSettings.apimSettings.apimPublisherName
    skuName: globalSettings.apimSettings.apimSkuName
    keyVaultName: shared[0].outputs.resources.keyVaultName!
    keyVaultRG: sharedRG.name
    primaryRegionSettings: regionalSettings[0]
    additionalRegionSettings: skip(regionalSettings,1)
    additionalRegionsNetworkingResources: skip(networkingModule.outputs.networkingResourcesArray,1) 
    deployCustomDnsNames: true
    apimCustomDomainName: globalSettings.apimSettings.apimCustomDomainName
    certificateSecretUriWithoutVersion: appgwModule.outputs.certificateSecretUriWithoutVersion
  }
}
