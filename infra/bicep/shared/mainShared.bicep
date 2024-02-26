import {vNetSettingsType,  locationSettingType, sharedResourcesType} from '../bicepParamTypes.bicep'
// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

@description('The full id string identifying the target subnet for the jumpbox VM')
param jumpboxSubnetId string?

@description('The full id string identifying the target subnet for the CI/CD Agent VM')
param devOpsAgentSubnetId string?

@description('The user name to be used as the Administrator for all VMs created by this deployment')
param vmUsername string

@description('The password for the Administrator user for all VMs created by this deployment')
@secure()
param vmPassword string

@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param CICDAgentType string

@description('The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none')
param accountName string

@description('The Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent')
@secure()
param personalAccessToken string

@description('The name of the shared resource group')
param resourceGroupName string

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
var defaultWindowsOSVersion = '2022-datacenter-azure-edition'

param vnetId string
param keyVaultPrivateEndpointSubnetid string?
param keyVaultPrivateDnsZoneName string
param keyVaultPrivateDnsZoneId string

// Resources
module appInsights './monitoring.bicep' = {
  name: 'azmon${workloadName}${environment}${location}'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    environment: environment
    workloadName: workloadName
  }
}

module vmDevOps './createvmwindows.bicep' = if (toLower(CICDAgentType)!='none' && devOpsAgentSubnetId != null) {
  name: 'devopsvm${workloadName}${environment}${location}'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: devOpsAgentSubnetId!
    username: vmUsername
    password: vmPassword
    vmName: '${CICDAgentType}-${environment}'
    accountName: accountName
    personalAccessToken: personalAccessToken
    CICDAgentType: CICDAgentType
    deployAgent: true
    windowsOSVersion: defaultWindowsOSVersion
  }
}

module vmJumpBox './createvmwindows.bicep' = if (jumpboxSubnetId != null) {
  name: 'vm-jumpbox${workloadName}${environment}${location}'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: jumpboxSubnetId!
    username: vmUsername
    password: vmPassword
    CICDAgentType: CICDAgentType
    vmName: 'jumpbox-${environment}'
    windowsOSVersion: defaultWindowsOSVersion
  }
}

module keyVault './keyVault.bicep' = if (keyVaultPrivateEndpointSubnetid != null){
  name: 'keyvault-resource${workloadName}${environment}${location}'
  scope: resourceGroup(resourceGroupName)
  
  params: {
    keyVaultPrivateEndpointSubnetid: keyVaultPrivateEndpointSubnetid!
    vnetId: vnetId
    environment: environment
    workloadName: workloadName
    location: location
    keyVaultPrivateDnsZoneName: keyVaultPrivateDnsZoneName
    keyVaultPrivateDnsZoneId: keyVaultPrivateDnsZoneId
  }
}

output resources sharedResourcesType = {
  appInsightsConnectionString : appInsights.outputs.appInsightsConnectionString
  appInsightsName : appInsights.outputs.appInsightsName
  appInsightsId : appInsights.outputs.appInsightsId
  appInsightsInstrumentationKey : appInsights.outputs.appInsightsInstrumentationKey
  logAnalyticsWorkspaceId : appInsights.outputs.logAnalyticsWorkspaceId
  keyVaultName : keyVaultPrivateEndpointSubnetid != null ? keyVault.outputs.keyVaultName : null
}
