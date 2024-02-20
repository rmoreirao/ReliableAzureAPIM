targetScope='subscription'

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

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'


var functionsResourceGroupName = 'rg-backend-func-${resourceSuffix}'
var logicAppsResourceGroupName = 'rg-backend-logicapps-${resourceSuffix}'

var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Resource Names
var apimName = 'apim-${resourceSuffix}'
var appGatewayName = 'appgw-${resourceSuffix}'

var apimGatewayFQDN = '${apimName}.azure-api.net'
var apimGatewayCustomHostname = 'api.${apimCustomDomainName}'
var oldDevPortalFQDN = '${apimName}.portal.azure-api.net'
var oldDevPortalCustomHostname = 'portal.${apimCustomDomainName}'
var devPortalFQDN = '${apimName}.developer.azure-api.net'
var devPortalCustomHostname = 'developer.${apimCustomDomainName}'
var managementBackendEndFQDN = '${apimName}.management.azure-api.net'
var managementBackendEndCustomHostname = 'management.${apimCustomDomainName}'


resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}

resource backendFunctionsRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: functionsResourceGroupName
  location: location
}

resource backendLogicAppsRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: logicAppsResourceGroupName
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

module networking './networking/networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    deploymentEnvironment: environment
    location: location
  }
}

// module backendFunctions './backend/backendFunctions.bicep' = {
//   name: 'backendresourcesfunctions'
//   scope: resourceGroup(backendFunctionsRG.name)
//   params: {
//     workloadName: workloadName
//     environment: environment
//     location: location    
//     vnetName: networking.outputs.apimVNetName
//     vnetRG: networkingRG.name
//     functiounsOutboundSubnetId: networking.outputs.functionsOutboundSubnetid
//     functionsInboundPrivateEndpointSubnetid: networking.outputs.functionsInboundSubnetid
//   }
// }

// module backendLogicApps './backend/backendLogicApps.bicep' = {
//   name: 'backendresourceslogicapps'
//   scope: resourceGroup(backendLogicAppsRG.name)
//   params: {
//     workloadName: workloadName
//     environment: environment
//     location: location    
//     vnetName: networking.outputs.apimVNetName
//     vnetRG: networkingRG.name
//     logicAppsOutboundSubnetId: networking.outputs.logicAppsOutboundSubnetid
//     logicAppsInboundPrivateEndpointSubnetid: networking.outputs.logicAppsInboundSubnetid
//     logicAppsStorageInboundSubnetid: networking.outputs.logicAppsStorageInboundSubnetid
//   }
// }

var jumpboxSubnetId= networking.outputs.jumpBoxSubnetid
var CICDAgentSubnetId = networking.outputs.CICDAgentSubnetId

module shared './shared/shared.bicep' = {
  dependsOn: [
    networking
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    accountName: devOpsAccountName
    CICDAgentSubnetId: CICDAgentSubnetId
    CICDAgentType: devOpsCICDAgentType
    environment: environment
    jumpboxSubnetId: jumpboxSubnetId
    location: location
    personalAccessToken: devOpsPersonalAccessToken
    resourceGroupName: sharedRG.name
    resourceSuffix: resourceSuffix
    vmPassword: devOpsVmPassword
    vmUsername: devOpsVmUsername
  }
}

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    apimSubnetId: networking.outputs.apimSubnetid
    location: location
    appInsightsName: shared.outputs.appInsightsName
    appInsightsId: shared.outputs.appInsightsId
    appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
    publicIpAddressId: networking.outputs.publicIp
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}

//Creation of private DNS zones for APIM
module dnsZoneModule 'networking/apimdnszone.bicep'  = {
  name: 'apimDnsZoneDeploy'
  scope: resourceGroup(networkingRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetName: networking.outputs.apimVNetName
    vnetRG: networkingRG.name
    apimName: apimName
    apimPrivateIPAddress: apimModule.outputs.apimPrivateIpAddress
  }
}

module appgwModule 'apim/apimAppgw.bicep' = {
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
    appGatewaySubnetId: networking.outputs.appGatewaySubnetid
    apiGatewayFQDN: apimGatewayFQDN
    oldDevPortalFQDN: oldDevPortalFQDN  
    devPortalFQDN: devPortalFQDN
    managementFQDN: managementBackendEndFQDN
    apiGatewayCustomHostname: apimGatewayCustomHostname
    oldDevPortalCustomHostname: oldDevPortalCustomHostname
    devPortalCustomHostname: devPortalCustomHostname
    managementBackendEndCustomHostname: managementBackendEndCustomHostname
    keyVaultName: shared.outputs.keyVaultName
    keyVaultResourceGroupName: sharedRG.name
    appGatewayCertType: apimAppGatewayCertType
    certPassword: apimAppGatewayCertificatePassword
    logAnalyticsWorkspaceResourceId: shared.outputs.logAnalyticsWorkspaceId
  }
}
