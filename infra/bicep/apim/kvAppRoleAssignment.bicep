param keyVaultName string
param principalId  string      
param roleId string
// 'Key Vault Certificates Officer'
// var roleIdCertificatesOfficer = 'a4417e6f-fecd-4de8-b567-7b0420556985'

// get exisitng key vault by name
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

resource kvRoleAssignmentCert 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleId,principalId,keyVault.id)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
