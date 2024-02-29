
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

module kvRoleAssignmentsCert 'kvAppRoleAssignment.bicep' = {
  name: 'kvRoleAssignmentsCert'
  scope: resourceGroup(keyVaultRG)
  params: {
    keyVaultName: keyVaultName
    managedIdentity: managedIdentity
    // Key Vault Certificates Officer
    roleId: 'a4417e6f-fecd-4de8-b567-7b0420556985'
  }
}

module kvRoleAssignmentsSecret 'kvAppRoleAssignment.bicep' = {
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

var storageFileDataPrivilegedContributorRoleId =  '69566ab7-960f-475b-8e7c-b3118f30c6bd'
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount

  name: guid(storageFileDataPrivilegedContributorRoleId, managedIdentity.properties.principalId, storageAccount.id)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageFileDataPrivilegedContributorRoleId)
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

module getKeyVaultCertificateSecret 'getKeyVaultCertificateSecret.bicep' = {
  name: 'getKeyVaultCertificateSecret'
  params: {
    keyVaultName: keyVaultName
    secretName: secretName
    keyVaultRG: keyVaultRG
  }
  dependsOn: [
    appGatewayCertificate
  ]
}

output secretUri string = getKeyVaultCertificateSecret.outputs.secretUri

