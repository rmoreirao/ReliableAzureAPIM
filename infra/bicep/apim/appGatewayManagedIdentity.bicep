param location string = resourceGroup().location
var appGatewayIdentityName = 'identity-apimappgateway'

resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:     appGatewayIdentityName
  location: location
}

// grant reader role assignement to a resource group calling directly the ARM API
// This is required because we want to check if the APIM exists runing a deployment script
// The management identity of the deployment script must have this permission
// Reader role
var roleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
resource rgRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().subscriptionId, appGatewayIdentityName, roleId)
  scope: resourceGroup()
  properties: {
    principalId: appGatewayIdentity.properties.principalId
    
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',roleId )
    principalType: 'ServicePrincipal'
  }
}

output appGatewayIdentityPrincipalId string = appGatewayIdentity.properties.principalId
output appGatewayIdentityId string = appGatewayIdentity.id
