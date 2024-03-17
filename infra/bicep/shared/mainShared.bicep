import {vNetRegionalSettingsType,  regionalSettingType, sharedResourcesType,devOpsAgentSettingsType, jumpBoxSettingsType} from '../bicepParamTypes.bicep'
// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

param jumpBoxResourcesSettings jumpBoxSettingsType?

@description('The full id string identifying the target subnet for the jumpbox VM')
param jumpboxSubnetId string?

param devOpsResourcesSettings devOpsAgentSettingsType?

@description('The full id string identifying the target subnet for the CI/CD Agent VM')
param devOpsAgentSubnetId string?

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
param deployResources bool

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

module vmDevOps './createvmwindows.bicep' = if (devOpsResourcesSettings != null && devOpsResourcesSettings.?devOpsCICDAgentType != 'none' && devOpsAgentSubnetId != null) {
  name: 'devopsvm${workloadName}${environment}${location}'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: devOpsAgentSubnetId!
    username: devOpsResourcesSettings!.devOpsVmUsername
    password: devOpsResourcesSettings!.devOpsVmPassword
    vmName: '${devOpsResourcesSettings!.devOpsCICDAgentType}-${environment}'
    accountName: devOpsResourcesSettings!.devOpsAccountName
    personalAccessToken: devOpsResourcesSettings!.devOpsPersonalAccessToken
    CICDAgentType: devOpsResourcesSettings!.devOpsCICDAgentType
    deployAgent: true
    windowsOSVersion: defaultWindowsOSVersion
  }
}

module vmJumpBox './createvmwindows.bicep' = if (jumpBoxResourcesSettings != null && jumpboxSubnetId != null) {
  name: 'vm-jumpbox${workloadName}${environment}${location}'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: jumpboxSubnetId!
    username: jumpBoxResourcesSettings!.jumpBoxVmUsername
    password: jumpBoxResourcesSettings!.jumpBoxVmPassword
    CICDAgentType: 'none'
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
    deployResources: deployResources
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
