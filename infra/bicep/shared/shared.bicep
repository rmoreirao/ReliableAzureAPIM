targetScope='resourceGroup'
// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

@description('The full id string identifying the target subnet for the jumpbox VM')
param jumpboxSubnetId string

@description('The full id string identifying the target subnet for the CI/CD Agent VM')
param CICDAgentSubnetId string

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

@description('Standardized suffix text to be added to resource names')
param resourceSuffix string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

// Variables - ensure key vault name does not end with '-'
var tempKeyVaultName = take('kva-${resourceSuffix}', 24) // Must be between 3-24 alphanumeric characters 
var keyVaultName = endsWith(tempKeyVaultName, '-') ? substring(tempKeyVaultName, 0, length(tempKeyVaultName) - 1) : tempKeyVaultName
var defaultWindowsOSVersion = '2022-datacenter-azure-edition'

// Resources
module appInsights './monitoring.bicep' = {
  name: 'azmon'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    resourceSuffix: resourceSuffix
  }
}

module vmDevOps './createvmwindows.bicep' = if (toLower(CICDAgentType)!='none') {
  name: 'devopsvm'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: CICDAgentSubnetId
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

module vmJumpBox './createvmwindows.bicep' = {
  name: 'vm-jumpbox'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    subnetId: jumpboxSubnetId
    username: vmUsername
    password: vmPassword
    CICDAgentType: CICDAgentType
    vmName: 'jumpbox-${environment}'
    windowsOSVersion: defaultWindowsOSVersion
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }    
    accessPolicies: [
    ]
  }
}

// Outputs
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
output CICDAgentVmName string = vmDevOps.name
output jumpBoxvmName string = vmJumpBox.name
output appInsightsName string=appInsights.outputs.appInsightsName
output appInsightsId string=appInsights.outputs.appInsightsId
output appInsightsInstrumentationKey string=appInsights.outputs.appInsightsInstrumentationKey
output keyVaultName string = keyVault.name
output logAnalyticsWorkspaceId string = appInsights.outputs.logAnalyticsWorkspaceId