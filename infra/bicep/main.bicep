targetScope='subscription'
import {vNetSettingsType, devOpsResourcesSettingsType, jumpBoxResourcesSettingsType, locationSettingType, networkingResourcesType, sharedResourcesType, apimGlobalSettingsType, apimRegionalSettingsType} from 'bicepParamTypes.bicep'

// Parameters
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

param jumpBoxResourcesSettings jumpBoxResourcesSettingsType
param devOpsResourcesSettings devOpsResourcesSettingsType 

param apimGlobalSettings apimGlobalSettingsType

param location string = deployment().location

param locationSettings locationSettingType[]

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

// module networkingModule './networking/mainNetworking.bicep' = [for (locationSetting,i) in locationSettings: {
//   name: 'networkingresources${workloadName}${environment}${locationSetting.location}'
//   scope: resourceGroup(networkingRG.name)
//   params: {
//     workloadName: workloadName
//     environment: environment
//     location: locationSetting.location
//     vNetSettings: locationSetting.vNetSettings
//   }
// }]

module networkingModule './networking/mainNetworkingAllRegions.bicep' = {
  name: 'networkingresourcesallregions${workloadName}${environment}${location}'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    locationsSettings:locationSettings
  }
}

// resource backendRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
//   name: backendResourceGroupName
//   location: location
// }

// module backend './backend/mainBackend.bicep' = {
//   name: 'backendresources${workloadName}${environment}${locationSetting.location}'
//   scope: resourceGroup(backendRG.name)
//   params: {
//     workloadName: workloadName
//     environment: environment
//     location: location    
//     apimVNetName: networkingModule.outputs.apimVNetName
//     backendRGName: backendRG.name
//     functionsInboundSubnetid: networkingModule.outputs.functionsInboundSubnetid
//     functionsOutboundSubnetid: networkingModule.outputs.functionsOutboundSubnetid
//     logicAppsInboundSubnetid: networkingModule.outputs.logicAppsInboundSubnetid
//     logicAppsOutboundSubnetid: networkingModule.outputs.logicAppsOutboundSubnetid
//     logicAppsStorageInboundSubnetid: networkingModule.outputs.logicAppsStorageInboundSubnetid
//     vnetRGName: networkingRG.name
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

module shared './shared/mainShared.bicep' = [for (locationSetting,i) in locationSettings: {
  name: 'sharedresources${workloadName}${environment}${locationSetting.location}'
  scope: resourceGroup(sharedRG.name)
  params: {
    devOpsAgentSubnetId: networkingModule.outputs.networkingResourcesArray[i].?devOpsAgentSubnetId
    environment: environment
    jumpboxSubnetId: networkingModule.outputs.networkingResourcesArray[i].?jumpBoxSubnetid
    resourceGroupName: sharedRG.name
    devOpsResourcesSettings: devOpsResourcesSettings
    jumpBoxResourcesSettings:jumpBoxResourcesSettings
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


// resource apimRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
//   name: apimResourceGroupName
//   location: location
//   dependsOn: [
//     shared
//   ]
// }

// module apimPrivateDNSZone 'apim/apimPrivateDNSZonesGlobal.bicep' = {
//   name: 'apimPrivateDnsZoneDeploy${workloadName}${environment}${location}'
//   scope: resourceGroup(apimRG.name)
//   params: {
//   }
// }

// module apimModule 'apim/apim.bicep'  = {
//   name: 'apimDeploy${workloadName}${environment}${location}'
//   scope: resourceGroup(apimRG.name)
//   params: {
//     resourceSuffix: resourceSuffix
//     apimSubnetId: networkingModule.outputs.networkingResourcesArray[0].apimSubnetid
//     appInsightsName: shared[0].outputs.resources.appInsightsName
//     appInsightsId: shared[0].outputs.resources.appInsightsId
//     appInsightsInstrumentationKey: shared[0].outputs.resources.appInsightsInstrumentationKey
//     apimPublicIpId: networkingModule.outputs.networkingResourcesArray[0].apimPublicIpId
//     publisherEmail: apimGlobalSettings.apimPublisherEmail
//     publisherName: apimGlobalSettings.apimPublisherName
//     skuName: apimGlobalSettings.apimSkuName
//     keyVaultName: shared[0].outputs.resources.keyVaultName!
//     keyVaultRG: sharedRG.name
//     primaryRegionSettings: locationSettings[0]
//     additionalRegionSettings: skip(locationSettings,1)
//     additionalRegionsNetworkingResources: skip(networkingModule.outputs.networkingResourcesArray,1) 
//   }
// }



// //Creation of private DNS zones for APIM
// module dnsZoneModule 'apim/apimDnsZonesRegional.bicep'  =   [for (locationSetting,i) in locationSettings:{
//   name: 'apimDnsZoneDeploy${workloadName}${environment}${locationSetting.location}${i}'
//   scope: resourceGroup(apimRG.name)
//   dependsOn: [
//     apimModule
//   ]
//   params: {
//     vnetId: networkingModule.outputs.networkingResourcesArray[i].vnetId
//     apimName: apimModule.outputs.apimName
//     // TO DO: to add the private IP addresses of APIM regions here!!!
//     apimPrivateIPAddress: apimModule.outputs.apimPrivateIpAddress
//     apimDeveloperDnsZoneName: apimPrivateDNSZone.outputs.apimDeveloperDnsZoneName
//     apimManagementDnsZoneName: apimPrivateDNSZone.outputs.apimManagementDnsZoneName
//     apimGatewayDnsZoneName: apimPrivateDNSZone.outputs.apimGatewayDnsZoneName
//   }
// }]


// module appgwModule 'apim/appGateway.bicep' = {
//   name: 'appgwDeploy${workloadName}${environment}${location}'
//   scope: resourceGroup(apimRG.name)
//   dependsOn: [
//     apimModule
//     dnsZoneModule
//   ]
//   params: {
//     resourceSuffix: resourceSuffix
//     appGatewayFQDN: apimGlobalSettings.apimCustomDomainName
//     location: location
//     appGatewaySubnetId: networkingModule.outputs.networkingResourcesArray[0].appGatewaySubnetid
//     keyVaultName: shared[0].outputs.resources.keyVaultName!
//     keyVaultResourceGroupName: sharedRG.name
//     appGatewayCertType: apimGlobalSettings.apimAppGatewayCertType
//     certPassword: apimGlobalSettings.apimAppGatewayCertificatePassword
//     logAnalyticsWorkspaceResourceId: shared[0].outputs.resources.logAnalyticsWorkspaceId
//     deployScriptStorageSubnetId: networkingModule.outputs.networkingResourcesArray[0].deployScriptStorageSubnetId!
//     environment: environment
//     workloadName: workloadName
//     appGatewayPublicIPAddressId: networkingModule.outputs.networkingResourcesArray[0].appGatewayPublicIpId
//     apimName: apimModule.outputs.apimName
//     apimCustomDomainName: apimGlobalSettings.apimCustomDomainName
//   }
// }
