param keyVaultName string
param secretName string
param keyVaultRG string

resource keyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' existing = {
  name: '${keyVaultName}/${secretName}'
  scope: resourceGroup(keyVaultRG)
}

output secretUri string = keyVaultCertificate.properties.secretUriWithVersion
