var privateDNSZoneName = 'privatelink.azurewebsites.net'

param storageEnvironmentDomain string = 'windows.net'

var storageQueueDNSZoneName = 'privatelink.queue.core.${storageEnvironmentDomain}'
var storageBlobDNSZoneName = 'privatelink.blob.core.${storageEnvironmentDomain}'
var storageTableDNSZoneName = 'privatelink.table.core.${storageEnvironmentDomain}'
var storageFlieDNSZoneName = 'privatelink.file.core.${storageEnvironmentDomain}'


resource backendPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
}

resource storageQueuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: storageQueueDNSZoneName
  location: 'global'
}

resource storageBlobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: storageBlobDNSZoneName
  location: 'global'
}

resource storageTablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: storageTableDNSZoneName
  location: 'global'
}

resource storageFilePrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: storageFlieDNSZoneName
  location: 'global'
}

output backendPrivateDNSZoneName string = privateDNSZoneName
output backendPrivateDnsZoneId string = backendPrivateDnsZone.id

output storageQueuePrivateDNSZoneName string = storageQueueDNSZoneName
output storageQueuePrivateDnsZoneId string = storageQueuePrivateDnsZone.id

output storageBlobPrivateDNSZoneName string = storageBlobDNSZoneName
output storageBlobPrivateDnsZoneId string = storageBlobPrivateDnsZone.id

output storageTablePrivateDNSZoneName string = storageTableDNSZoneName
output storageTablePrivateDnsZoneId string = storageTablePrivateDnsZone.id

output storageFilePrivateDNSZoneName string = storageFlieDNSZoneName
output storageFilePrivateDnsZoneId string = storageFilePrivateDnsZone.id

