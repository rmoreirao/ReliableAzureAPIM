
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

param keyVaultName string
param keyVaultRG string
param managedIdentity         object      
param location                string
param appGatewayFQDN          string
@secure()
param certPassword            string  
param appGatewayCertType      string

var secretName = replace(appGatewayFQDN,'.', '-')
var subjectName='CN=${appGatewayFQDN}'

var certData = appGatewayCertType == 'selfsigned' ? 'null' : loadFileAsBase64('./appGwCerts/appgw.pfx')
var certPwd = appGatewayCertType == 'selfsigned' ? 'null' : certPassword

// TODO - not needed as using the RBAC for Key vault
// resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
//   name: '${keyVaultName}/add'
//   properties: {
//     accessPolicies: [
//       {
//         objectId: managedIdentity.properties.principalId
//         tenantId: managedIdentity.properties.tenantId
//         permissions: {
//           secrets: [ 
//             'get' 
//             'list'
//           ]
//           certificates: [
//             'import'
//             'get'
//             'list'
//             'update'
//             'create'
//           ]
//         }                  
//       }
//     ]
//   }
// }

module kvRoleAssignmentsCert 'kvAppGtwRoleAssignment.bicep' = {
  name: 'kvRoleAssignmentsCert'
  scope: resourceGroup(keyVaultRG)
  params: {
    keyVaultName: keyVaultName
    managedIdentity: managedIdentity
    // Key Vault Certificates Officer
    roleId: 'a4417e6f-fecd-4de8-b567-7b0420556985'
  }
}

module kvRoleAssignmentsSecret 'kvAppGtwRoleAssignment.bicep' = {
  name: 'kvRoleAssignmentsSecret'
  scope: resourceGroup(keyVaultRG)
  params: {
    keyVaultName: keyVaultName
    managedIdentity: managedIdentity
    // Key Vault Secrets User
    roleId: '4633458b-17de-408a-b874-0445c86b69e6'
  }
  dependsOn: [
    kvRoleAssignmentsCert
  ]
}

var storageAccountName  = toLower(take(replace('stbdscr${workloadName}${environment}${location}', '-',''), 24))

var storageAccountSku  = 'Standard_LRS'
var storageAccountKind  = 'StorageV2'

var storageAccounts_minTLSVersion = 'TLS1_2'

param deployScriptStorageSubnetId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  properties: {
    minimumTlsVersion: storageAccounts_minTLSVersion
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: deployScriptStorageSubnetId
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource storageFileDataPrivilegedContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Privileged Contributor
  scope: tenant()
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount

  name: guid(storageFileDataPrivilegedContributor.id, managedIdentity.properties.principalId, storageAccount.id)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: storageFileDataPrivilegedContributor.id
    principalType: 'ServicePrincipal'
  }
}

resource appGatewayCertificate 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: '${secretName}-certificate'
  dependsOn: [
    kvRoleAssignmentsSecret
  ]
  location: location 
  kind: 'AzurePowerShell'
  properties: {
    storageAccountSettings: {
      storageAccountName: storageAccount.name
      storageAccountKey: storageAccount.listKeys().keys[0].value
    }
    containerSettings: {
      subnetIds: [
        {
          id: deployScriptStorageSubnetId
        }
      ]
    }
    azPowerShellVersion: '6.6'
    arguments: ' -vaultName ${keyVaultName} -certificateName ${secretName} -subjectName ${subjectName} -certPwd ${certPwd} -certDataString ${certData} -certType ${appGatewayCertType}'
    scriptContent: loadTextContent('./scripts/appGatewayCertToKv.ps1')
    retentionInterval: 'P1D'
    // timeout 20 minutes
    timeout: 'PT20M'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${managedIdentity.subscriptionId}/resourceGroups/${managedIdentity.resourceGroupName}/providers/${managedIdentity.resourceId}': {}
    }
  }
}

resource keyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' existing = {
  name: '${keyVaultName}/${secretName}'
  scope: resourceGroup(keyVaultRG)
}

output secretUri string = keyVaultCertificate.properties.secretUriWithVersion
