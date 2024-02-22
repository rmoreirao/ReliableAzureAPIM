targetScope='subscription'
import {vNetSettingsType, additionalRegionsType} from 'exportParamTypes.bicep'

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

param vNetSettings vNetSettingsType
// param additionalRegions additionalRegionsType[]

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'

var backendResourceGroupName = 'rg-backend-${resourceSuffix}'

var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Resource Names
var apimName = 'apim-${resourceSuffix}'
var appGatewayName = 'appgw-${resourceSuffix}'

var apimGatewayFQDN = '${apimName}.azure-api.net'
var apimGatewayCustomHostname = 'api.${apimCustomDomainName}'
var devPortalFQDN = '${apimName}.developer.azure-api.net'
var devPortalCustomHostname = 'developer.${apimCustomDomainName}'
var managementBackendEndFQDN = '${apimName}.management.azure-api.net'
var managementBackendEndCustomHostname = 'management.${apimCustomDomainName}'


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

module networkingModule './networking/mainNetworking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    location: location
    vNetSettings: vNetSettings
  }
}

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

module shared './shared/shared.bicep' = {
  dependsOn: [
    networkingModule
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    accountName: devOpsAccountName
    CICDAgentSubnetId: networkingModule.outputs.CICDAgentSubnetId
    CICDAgentType: devOpsCICDAgentType
    environment: environment
    jumpboxSubnetId: networkingModule.outputs.jumpBoxSubnetid
    location: location
    personalAccessToken: devOpsPersonalAccessToken
    resourceGroupName: sharedRG.name
    resourceSuffix: resourceSuffix
    vmPassword: devOpsVmPassword
    vmUsername: devOpsVmUsername
    vnetName: networkingModule.outputs.apimVNetName
    vnetRG: networkingRG.name
    keyVaultPrivateEndpointSubnetid: networkingModule.outputs.logicAppsStorageInboundSubnetid
  }
}

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    apimSubnetId: networkingModule.outputs.apimSubnetid
    location: location
    appInsightsName: shared.outputs.appInsightsName
    appInsightsId: shared.outputs.appInsightsId
    appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
    apimPublicIpId: networkingModule.outputs.publicIpId
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}


// module firwall './networking/firewall.bicep' = {
//   name: 'networkingfirewallresources'
//   scope: resourceGroup(networkingRG.name)
//   params: {
//     workloadName: workloadName
//     deploymentEnvironment: environment
//     location: location
//     apimVNetName: networkingModule.outputs.apimVNetName
//     firewallSubnetName: networkingModule.outputs.firewallSubnetName
//     udrApimFirewallName: networkingModule.outputs.udrApimFirewallName
//     firewallManagementSubnetName: networkingModule.outputs.firewallManagementSubnetName
//   }
//   dependsOn: [
//     networkingModule
//   ]
// }


//Creation of private DNS zones for APIM
module dnsZoneModule 'apim/apimDnsZones.bicep'  = {
  name: 'apimDnsZoneDeploy'
  scope: resourceGroup(networkingRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetName: networkingModule.outputs.apimVNetName
    vnetRG: networkingRG.name
    apimName: apimName
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
    appGatewayName: appGatewayName
    appGatewayFQDN: apimCustomDomainName
    location: location
    appGatewaySubnetId: networkingModule.outputs.appGatewaySubnetid
    apiGatewayFQDN: apimGatewayFQDN
    devPortalFQDN: devPortalFQDN
    managementFQDN: managementBackendEndFQDN
    apiGatewayCustomHostname: apimGatewayCustomHostname
    devPortalCustomHostname: devPortalCustomHostname
    managementBackendEndCustomHostname: managementBackendEndCustomHostname
    keyVaultName: shared.outputs.keyVaultName
    keyVaultResourceGroupName: sharedRG.name
    appGatewayCertType: apimAppGatewayCertType
    certPassword: apimAppGatewayCertificatePassword
    logAnalyticsWorkspaceResourceId: shared.outputs.logAnalyticsWorkspaceId
    deployScriptStorageSubnetId: networkingModule.outputs.deployScriptStorageSubnetId
    environment: environment
    workloadName: workloadName
    appGatewayPublicIPAddressId: networkingModule.outputs.appGatewayPublicIpId
  }
}
