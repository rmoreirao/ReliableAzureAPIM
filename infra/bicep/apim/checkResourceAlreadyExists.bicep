// https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.resources/deployment-script-azcli-inputs-outputs
targetScope = 'resourceGroup'

@description('Resource name to check in current scope (resource group)')
param resourceName string

@description('Resource ID of user managed identity with reader permissions in current scope')
param identityId string
param deployManagedIdentityPrincipalId string

param location string = resourceGroup().location
param utcValue string = utcNow()
param resourceGroupName string = resourceGroup().name

var subscriptionId = subscription().subscriptionId

// Grant the reader role to the user managed identity in the Resource Group
// this is required to run the script that checks if the resource exists
var readerRoleId =  'acdd72a7-3385-48ef-bd42-f606fba81ae7'
resource roleAssignmentReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()

  name: guid(resourceGroupName, subscriptionId, readerRoleId)
  properties: {
    principalId: deployManagedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)
    principalType: 'ServicePrincipal'
  }
}

var scriptContent = loadTextContent('./scripts/checkResourceExists.sh')
var arguments = [
  resourceGroupName
  resourceName
  subscriptionId
]
// The script below performs an 'az resource list' command to determine whether a resource exists
resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'resource_exists'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.50.0'
    timeout: 'PT10M'
    arguments: join(arguments, ' ')
    scriptContent: scriptContent
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

resource logs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: script
  name: 'default'
}

@description('The logs written by the script')
output logs array = split(logs.properties.log, '\n')

@description('Whether the resource exists')
output exists bool = script.properties.outputs.RESOURCE_EXISTS == 'true'
