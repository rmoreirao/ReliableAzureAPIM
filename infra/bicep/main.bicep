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
  name: 'mainNetworkingAllRegions${workloadName}${environment}${location}'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    locationsSettings:regionalSettings
    firewallSku: globalSettings.networkingRGSettings.?firewallSettings.?firewallSkuName
    firewallAvailabilityZones: globalSettings.networkingRGSettings.?firewallSettings.?availabilityZones
    deployResources: globalSettings.networkingRGSettings.deployResources
  }
}

resource backendRG 'Microsoft.Resources/resourceGroups@2021-04-01' = if (globalSettings.backendRGSettings.deployResources) {
  name: backendResourceGroupName
  location: location
}

module backendDns './backend/backendPrivateDnsGlobal.bicep' = if (globalSettings.backendRGSettings.deployResources) {
  name: 'backendPrivateDnsGlobal${workloadName}${environment}${regionalSettings[0].location}'
  scope: resourceGroup(backendRG.name)
}

// Deploy the Backend resources (Logic Apps & Functions) only to a Single Region
// This can be adjusted to deploy to multiple regions in the future by adding a loop similar to the networking module
module backend './backend/mainBackend.bicep' = if (globalSettings.backendRGSettings.deployResources) {
  name: 'backendresources${workloadName}${environment}${regionalSettings[0].location}'
  scope: resourceGroup(backendRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    backendRGName: backendRG.name
    functionsInboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?functionsInboundSubnetid
    functionsOutboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?functionsOutboundSubnetid
    logicAppsInboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?logicAppsInboundSubnetid
    logicAppsOutboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?logicAppsOutboundSubnetid
    logicAppsStorageInboundSubnetid: networkingModule.outputs.networkingResourcesArray[0].?logicAppsStorageInboundSubnetid
    vnetId: networkingModule.outputs.networkingResourcesArray[0].vnetId
    backendPrivateDnsZoneId: backendDns.outputs.backendPrivateDnsZoneId
    backendPrivateDNSZoneName: backendDns.outputs.backendPrivateDNSZoneName
    storageBlobPrivateDnsZoneId: backendDns.outputs.storageBlobPrivateDnsZoneId
    storageBlobPrivateDNSZoneName: backendDns.outputs.storageBlobPrivateDNSZoneName
    storageFilePrivateDnsZoneId: backendDns.outputs.storageFilePrivateDnsZoneId
    storageFilePrivateDNSZoneName: backendDns.outputs.storageFilePrivateDNSZoneName
    storageQueuePrivateDnsZoneId: backendDns.outputs.storageQueuePrivateDnsZoneId
    storageQueuePrivateDNSZoneName: backendDns.outputs.storageQueuePrivateDNSZoneName
    storageTablePrivateDnsZoneId: backendDns.outputs.storageTablePrivateDnsZoneId
    storageTablePrivateDNSZoneName: backendDns.outputs.storageTablePrivateDNSZoneName
    storageSku: globalSettings.backendRGSettings.?storageSku
  }
}

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
    devOpsResourcesSettings: globalSettings.sharedRGSettings.?devOpsAgentSettings
    jumpBoxResourcesSettings: globalSettings.sharedRGSettings.?jumpBoxSettings
    workloadName: workloadName
    keyVaultPrivateEndpointSubnetid: networkingModule.outputs.networkingResourcesArray[i].?keyVaultPrivateEndpointSubnetid
    location: locationSetting.location
    vnetId: networkingModule.outputs.networkingResourcesArray[i].vnetId
    keyVaultPrivateDnsZoneName: sharedPrivateDNSZone.outputs.keyVaultPrivateDNSZoneName
    keyVaultPrivateDnsZoneId: sharedPrivateDNSZone.outputs.keyVaultPrivateDNSZoneId
    deployResources: globalSettings.sharedRGSettings.deployResources
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

module apimPrivateDNSZone 'apim/apimPrivateDNSZonesGlobal.bicep' = if (globalSettings.apimRGSettings.apimSettings.deployResources) {
  name: 'apimPrivateDNSZonesGlobal${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
  }
}

module appGatewayIdentity 'apim/appGatewayManagedIdentity.bicep' = {
  name: 'appGatewayManagedIdentity${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
    location: location
  }
}

var apimName = 'apima-${resourceSuffix}'

module checkResourceAlreadyExists 'apim/checkResourceAlreadyExists.bicep' = {
  name: 'checkResourceAlreadyExists${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
    identityId: appGatewayIdentity.outputs.appGatewayIdentityId
    resourceName:apimName
    location:location
  }
}

module apimCertificate 'apim/apimCertificate.bicep' = [for (locationSetting,i) in regionalSettings: {
  name: 'apimCertificate${workloadName}${environment}${locationSetting.location}${i}'
  scope: resourceGroup(apimRG.name)
  params: {
    appGatewayFQDN: globalSettings.apimRGSettings.apimSettings.apimCustomDomainName
    location: locationSetting.location
    keyVaultName: shared[i].outputs.resources.keyVaultName!
    keyVaultRG: sharedRG.name
    appGatewayCertType: globalSettings.apimRGSettings.appGatewaySettings.apimAppGatewayCertType
    certPassword: globalSettings.apimRGSettings.appGatewaySettings.apimAppGatewayCertificatePassword
    deployScriptStorageSubnetId: networkingModule.outputs.networkingResourcesArray[i].deployScriptStorageSubnetId!
    environment: environment
    workloadName: workloadName
    deployResources: globalSettings.apimRGSettings.appGatewaySettings.deployResources
    appGatewayIdentityPrincipalId: appGatewayIdentity.outputs.appGatewayIdentityPrincipalId
    appGatewayIdentityId: appGatewayIdentity.outputs.appGatewayIdentityId
  }
}]

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    existsApim: checkResourceAlreadyExists.outputs.exists
    apimSubnetId: networkingModule.outputs.networkingResourcesArray[0].apimSubnetid
    appInsightsName: shared[0].outputs.resources.appInsightsName
    appInsightsId: shared[0].outputs.resources.appInsightsId
    appInsightsInstrumentationKey: shared[0].outputs.resources.appInsightsInstrumentationKey
    apimPublicIpId: networkingModule.outputs.networkingResourcesArray[0].apimPublicIpId
    publisherEmail: globalSettings.apimRGSettings.apimSettings.apimPublisherEmail
    publisherName: globalSettings.apimRGSettings.apimSettings.apimPublisherName
    skuName: globalSettings.apimRGSettings.apimSettings.apimSkuName
    keyVaultName: shared[0].outputs.resources.keyVaultName!
    keyVaultRG: sharedRG.name
    primaryRegionSettings: regionalSettings[0]
    additionalRegionSettings: skip(regionalSettings,1)
    additionalRegionsNetworkingResources: skip(networkingModule.outputs.networkingResourcesArray,1) 
    entraIdClientId: globalSettings.apimRGSettings.apimSettings.?entraIdClientId
    entraIdClientSecret: globalSettings.apimRGSettings.apimSettings.?entraIdClientSecret
    deployResources: globalSettings.apimRGSettings.apimSettings.deployResources
    apimCustomDomainName: globalSettings.apimRGSettings.apimSettings.apimCustomDomainName
    certificateSecretUriWithoutVersion: apimCertificate[0].outputs.secretUriWithoutVersion
  }
}


//Creation of private DNS zones for APIM
module dnsZoneModule 'apim/apimDnsZonesRegional.bicep'  =  [for (locationSetting,i) in regionalSettings: if (globalSettings.apimRGSettings.apimSettings.deployResources){
  name: 'apimDnsZonesRegional${workloadName}${environment}${locationSetting.location}${i}'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetId: networkingModule.outputs.networkingResourcesArray[i].vnetId
    apimName: apimModule.outputs.apimName
    apimPrivateIPAddress: apimModule.outputs.apimRegionalResources[i].apimPrivateIpAddress
    apimGatewayDnsZoneName: apimPrivateDNSZone.outputs.apimGatewayDnsZoneName
    apimGatewayRegionalUrl: apimModule.outputs.apimRegionalResources[i].apimGatewayURL
    // Only create Dns entries for DevPortal and Management on the primary region
    apimDeveloperDnsZoneName: apimPrivateDNSZone.outputs.apimDeveloperDnsZoneName
    apimDevPortalRegionalUrl: apimModule.outputs.apimRegionalResources[i].?apimDevPortalURL

    apimManagementDnsZoneName: apimPrivateDNSZone.outputs.apimManagementDnsZoneName
    apimManagementRegionalUrl: apimModule.outputs.apimRegionalResources[i].?apimManagementBackendEndURL
  }
}]


module appgwModule 'apim/appGateway.bicep' = [for (locationSetting,i) in regionalSettings: {
  name: 'appgwDeploy${workloadName}${environment}${locationSetting.location}${i}'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
    dnsZoneModule
  ]
  params: {
    appGatewayFQDN: globalSettings.apimRGSettings.apimSettings.apimCustomDomainName
    location: locationSetting.location
    appGatewaySubnetId: networkingModule.outputs.networkingResourcesArray[i].appGatewaySubnetid
    keyVaultName: shared[i].outputs.resources.keyVaultName!
    keyVaultResourceGroupName: sharedRG.name
    appGatewayCertType: globalSettings.apimRGSettings.appGatewaySettings.apimAppGatewayCertType
    certPassword: globalSettings.apimRGSettings.appGatewaySettings.apimAppGatewayCertificatePassword
    logAnalyticsWorkspaceResourceId: shared[i].outputs.resources.logAnalyticsWorkspaceId
    deployScriptStorageSubnetId: networkingModule.outputs.networkingResourcesArray[i].deployScriptStorageSubnetId!
    environment: environment
    workloadName: workloadName
    appGatewayPublicIPAddressId: networkingModule.outputs.networkingResourcesArray[i].appGatewayPublicIpId
    apimCustomDomainName: globalSettings.apimRGSettings.apimSettings.apimCustomDomainName
    sku:globalSettings.apimRGSettings.appGatewaySettings.appGatewaySkuName
    minCapacity: globalSettings.apimRGSettings.appGatewaySettings.minCapacity
    maxCapacity: globalSettings.apimRGSettings.appGatewaySettings.maxCapacity
    zones: globalSettings.apimRGSettings.appGatewaySettings.?availabilityZones
    apimGatewayURL: apimModule.outputs.apimRegionalResources[i].apimGatewayURL
    apimDevPortalURL: apimModule.outputs.apimRegionalResources[i].?apimDevPortalURL
    apimManagementBackendEndURL: apimModule.outputs.apimRegionalResources[i].?apimManagementBackendEndURL
    deployResources: globalSettings.apimRGSettings.appGatewaySettings.deployResources
    appGatewayIdentityPrincipalId: appGatewayIdentity.outputs.appGatewayIdentityPrincipalId
    appGatewayIdentityId: appGatewayIdentity.outputs.appGatewayIdentityId
    apiGatewayCertificateSecretUriWithVersion: apimCertificate[i].outputs.secretUriWithVersion
  }
}]
