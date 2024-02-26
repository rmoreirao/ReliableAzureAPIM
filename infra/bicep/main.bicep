targetScope='subscription'
import {vNetSettingsType, locationSettingType, networkingResourcesType, sharedResourcesType, apimGlobalSettingsType, apimRegionalSettingsType} from 'bicepParamTypes.bicep'

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

@description('The user name to be used as the Administrator for all VMs created by this deployment')
param devOpsVmUsername string

@description('The password for the Administrator user for all VMs created by this deployment')
@secure()
param devOpsVmPassword string = ''

@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param devOpsCICDAgentType string

@description('The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none')
param devOpsAccountName string

@description('The Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent')
@secure()
param devOpsPersonalAccessToken string = ''

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

module networkingModule './networking/mainNetworking.bicep' = [for (locationSetting,i) in locationSettings: {
  name: 'networkingresources${workloadName}${environment}${locationSetting.location}'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    location: locationSetting.location
    vNetSettings: locationSetting.vNetSettings
  }
}]

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
    accountName: devOpsAccountName
    devOpsAgentSubnetId: networkingModule[i].outputs.resources.?devOpsAgentSubnetId
    CICDAgentType: devOpsCICDAgentType
    environment: environment
    jumpboxSubnetId: networkingModule[i].outputs.resources.?jumpBoxSubnetid
    personalAccessToken: devOpsPersonalAccessToken
    resourceGroupName: sharedRG.name
    vmPassword: devOpsVmPassword
    vmUsername: devOpsVmUsername
    workloadName: workloadName
    keyVaultPrivateEndpointSubnetid: networkingModule[i].outputs.resources.?keyVaultPrivateEndpointSubnetid
    location: locationSetting.location
    vnetId: networkingModule[i].outputs.resources.vnetId
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

module apimPrivateDNSZone 'apim/apimPrivateDNSZonesGlobal.bicep' = {
  name: 'apimPrivateDnsZoneDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
  }
}

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  params: {
    resourceSuffix: resourceSuffix
    apimSubnetId: networkingModule[0].outputs.resources.apimSubnetid
    location: location
    appInsightsName: shared[0].outputs.resources.appInsightsName
    appInsightsId: shared[0].outputs.resources.appInsightsId
    appInsightsInstrumentationKey: shared[0].outputs.resources.appInsightsInstrumentationKey
    apimPublicIpId: networkingModule[0].outputs.resources.apimPublicIpId
    publisherEmail: apimGlobalSettings.apimPublisherEmail
    publisherName: apimGlobalSettings.apimPublisherName
    capacity: locationSettings[0].apimRegionalSettings.skuCapacity
    skuName: apimGlobalSettings.apimSkuName
  }
}



//Creation of private DNS zones for APIM
module dnsZoneModule 'apim/apimDnsZones.bicep'  =  {
  name: 'apimDnsZoneDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetId: networkingModule[0].outputs.resources.vnetId
    apimName: apimModule.outputs.apimName
    apimPrivateIPAddress: apimModule.outputs.apimPrivateIpAddress
    apimDeveloperDnsZoneName: apimPrivateDNSZone.outputs.apimDeveloperDnsZoneName
    apimManagementDnsZoneName: apimPrivateDNSZone.outputs.apimManagementDnsZoneName
    apimGatewayDnsZoneName: apimPrivateDNSZone.outputs.apimGatewayDnsZoneName
  }
}

module appgwModule 'apim/appGateway.bicep' = {
  name: 'appgwDeploy${workloadName}${environment}${location}'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
    dnsZoneModule
  ]
  params: {
    resourceSuffix: resourceSuffix
    appGatewayFQDN: apimGlobalSettings.apimCustomDomainName
    location: location
    appGatewaySubnetId: networkingModule[0].outputs.resources.appGatewaySubnetid
    keyVaultName: shared[0].outputs.resources.keyVaultName!
    keyVaultResourceGroupName: sharedRG.name
    appGatewayCertType: apimGlobalSettings.apimAppGatewayCertType
    certPassword: apimGlobalSettings.apimAppGatewayCertificatePassword
    logAnalyticsWorkspaceResourceId: shared[0].outputs.resources.logAnalyticsWorkspaceId
    deployScriptStorageSubnetId: networkingModule[0].outputs.resources.deployScriptStorageSubnetId!
    environment: environment
    workloadName: workloadName
    appGatewayPublicIPAddressId: networkingModule[0].outputs.resources.appGatewayPublicIpId
    apimName: apimModule.outputs.apimName
    apimCustomDomainName: apimGlobalSettings.apimCustomDomainName
  }
}
