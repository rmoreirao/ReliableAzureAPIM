var keyVaultPrivateDNSZoneName = 'privatelink.vaultcore.azure.net'


resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: keyVaultPrivateDNSZoneName
  location: 'global'
}

output keyVaultPrivateDNSZoneName string = keyVaultPrivateDNSZoneName
output keyVaultPrivateDNSZoneId string = keyVaultPrivateDnsZone.id

