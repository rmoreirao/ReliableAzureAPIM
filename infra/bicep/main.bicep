targetScope='subscription'
import {vNetSettingsType, locationSettingType, networkingOutputType} from 'exportParamTypes.bicep'

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

@description('Custom domain for APIM - is used to API Management from the internet. This should also match the Domain name of your Certificate. Example - contoso.com.')
param apimCustomDomainName string

@description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to deployment/bicep/gateway/certs/appgw.pfx')
@secure()
param apimAppGatewayCertificatePassword string

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
@allowed([
  'selfsigned'
  'custom'
])
param apimAppGatewayCertType string

@description('The email address of the publisher of the APIM resource.')
@minLength(1)
param apimPublisherEmail string

@description('Company name of the publisher of the APIM resource.')
@minLength(1)
param apimPublisherName string

param location string = deployment().location

// param vNetSettings vNetSettingsType

param locationSettings locationSettingType[]

// param additionalRegions additionalRegionsType[]

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

resource backendRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: backendResourceGroupName
  location: location
}


resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

resource apimRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apimResourceGroupName
  location: location
}

module networkingModule './networking/mainNetworkingLocation.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment

    locationSettings: locationSettings
    // additionalRegions: []
  }
}

output outputTest object = networkingModule.outputs

// module backend './backend/mainBackend.bicep' = {
//   name: 'backendresources'
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

module shared './shared/mainShared.bicep' = {
  dependsOn: [
    networkingModule
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    accountName: devOpsAccountName
    CICDAgentSubnetId: networkingModule.outputs.outputArray[0].?CICDAgentSubnetId
    CICDAgentType: devOpsCICDAgentType
    environment: environment
    jumpboxSubnetId: networkingModule.outputs.outputArray[0].?jumpBoxSubnetid
    location: location
    personalAccessToken: devOpsPersonalAccessToken
    resourceGroupName: sharedRG.name
    resourceSuffix: resourceSuffix
    vmPassword: devOpsVmPassword
    vmUsername: devOpsVmUsername
    vnetName: networkingModule.outputs.outputArray[0].apimVNetName
    vnetRG: networkingRG.name
    keyVaultPrivateEndpointSubnetid: networkingModule.outputs.outputArray[0].logicAppsStorageInboundSubnetid
  }
}

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    resourceSuffix: resourceSuffix
    apimSubnetId: networkingModule.outputs.outputArray[0].apimSubnetid
    location: location
    appInsightsName: shared.outputs.appInsightsName
    appInsightsId: shared.outputs.appInsightsId
    appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
    apimPublicIpId: networkingModule.outputs.outputArray[0].apimPublicIpId
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}



//Creation of private DNS zones for APIM
module dnsZoneModule 'apim/apimDnsZones.bicep'  = {
  name: 'apimDnsZoneDeploy'
  scope: resourceGroup(networkingRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetName: networkingModule.outputs.outputArray[0].apimVNetName
    vnetRG: networkingRG.name
    apimName: apimModule.outputs.apimName
    apimPrivateIPAddress: apimModule.outputs.apimPrivateIpAddress
  }
}

module appgwModule 'apim/appGateway.bicep' = {
  name: 'appgwDeploy'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
    dnsZoneModule
  ]
  params: {
    resourceSuffix: resourceSuffix
    appGatewayFQDN: apimCustomDomainName
    location: location
    appGatewaySubnetId: networkingModule.outputs.outputArray[0].appGatewaySubnetid
    keyVaultName: shared.outputs.keyVaultName
    keyVaultResourceGroupName: sharedRG.name
    appGatewayCertType: apimAppGatewayCertType
    certPassword: apimAppGatewayCertificatePassword
    logAnalyticsWorkspaceResourceId: shared.outputs.logAnalyticsWorkspaceId
    deployScriptStorageSubnetId: networkingModule.outputs.outputArray[0].deployScriptStorageSubnetId
    environment: environment
    workloadName: workloadName
    appGatewayPublicIPAddressId: networkingModule.outputs.outputArray[0].appGatewayPublicIpId
    apimName: apimModule.outputs.apimName
    apimCustomDomainName: apimCustomDomainName
  }
}
