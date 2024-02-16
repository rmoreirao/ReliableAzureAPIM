param subscriptionId string
param name string
param location string
param use32BitWorkerProcess bool
param ftpsState string
param storageAccountName string
param linuxFxVersion string = 'DOTNET-ISOLATED|8.0'
param sku string = 'ElasticPremium'
param skuCode string = 'EP1'
param workerSize string = '3'
param workerSizeId string = '3'
param numberOfWorkers string = '1'
param hostingPlanName string
param serverFarmResourceGroup string
param alwaysOn bool = false

var inboundSubnetDeployment_var = 'inboundSubnetDeployment'
var outboundSubnetDeployment_var = 'outboundSubnetDeployment'
var storageSubnetDeployment_var = 'storageSubnetDeployment'
var inboundPrivateDnsZoneName = 'privatelink.azurewebsites.net'
var inboundPrivateDnsZoneARecordName = 'inboundPrivateDnsZoneARecordName'
var privateEndpointStorageFileName = '${storageAccountName}-file-private-endpoint'
var privateEndpointStorageTableName = '${storageAccountName}-table-private-endpoint'
var privateEndpointStorageBlobName = '${storageAccountName}-blob-private-endpoint'
var privateEndpointStorageQueueName = '${storageAccountName}-queue-private-endpoint'
var privateStorageFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var privateStorageTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateStorageQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'

resource name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  location: location
  tags: {}
  kind: 'functionapp,linux'
  properties: {
    name: name
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id,'2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id,'2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'rmoreirao-func-apimab0f'
        }
      ]
      cors: {
        allowedOrigins: ['https://portal.azure.com']
      }
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      linuxFxVersion: linuxFxVersion
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: resourceId(
      'rg-networking-rmor2-dev-westeurope-001',
      'Microsoft.Network/virtualNetworks/subnets',
      'vnet-apim-cs-rmor2-dev-westeurope',
      'snet-func-apim-outbound'
    )
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true
    httpsOnly: true
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
  }
  dependsOn: [
    hostingPlan

    outboundSubnetDeployment
    inboundSubnetDeployment
  ]
}

resource hostingPlan 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: skuCode
    tier: sku
    
  }
  kind: 'linux'
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    reserved: true
    maximumElasticWorkerCount: '20'
    zoneRedundant: false
  }
  dependsOn: []
}

module inboundSubnetDeployment './nested_inboundSubnetDeployment.bicep' = {
  name: inboundSubnetDeployment_var
  scope: resourceGroup(
    'afb8f550-216d-4848-b6f1-73b1bbf58f1e',
    'rg-networking-rmor2-dev-westeurope-001'
  )
  params: {}
  dependsOn: []
}

module outboundSubnetDeployment './nested_outboundSubnetDeployment.bicep' = {
  name: outboundSubnetDeployment_var
  scope: resourceGroup(
    'afb8f550-216d-4848-b6f1-73b1bbf58f1e',
    'rg-networking-rmor2-dev-westeurope-001'
  )
  params: {}
  dependsOn: [inboundSubnetDeployment]
}

module storageSubnetDeployment './nested_storageSubnetDeployment.bicep' = {
  name: storageSubnetDeployment_var
  scope: resourceGroup(
    'afb8f550-216d-4848-b6f1-73b1bbf58f1e',
    'rg-networking-rmor2-dev-westeurope-001'
  )
  params: {}
  dependsOn: [inboundSubnetDeployment, outboundSubnetDeployment]
}

resource pe_apim_func_inbound 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-apim-func-inbound'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks/subnets',
        'vnet-apim-cs-rmor2-dev-westeurope',
        'snet-func-apim-inbound'
      )
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-apim-func-inbound'
        properties: {
          privateLinkServiceId: name_resource.id
          groupIds: ['sites']
        }
      }
    ]
  }
  dependsOn: [inboundSubnetDeployment]
}

resource inboundPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: inboundPrivateDnsZoneName
  location: 'global'
  dependsOn: [pe_apim_func_inbound]
}

resource pe_apim_func_inbound_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: pe_apim_func_inbound
  name: 'default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${inboundPrivateDnsZoneName}-config'
        properties: {
          privateDnsZoneId: inboundPrivateDnsZone.id
        }
      }
    ]
  }
}

resource inboundPrivateDnsZoneName_name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: inboundPrivateDnsZone
  name: '${name}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks',
        'vnet-apim-cs-rmor2-dev-westeurope'
      )
    }
    registrationEnabled: false
  }
  dependsOn: [pe_apim_func_inbound]
}

resource pe_func_apim_stg_privateEndpointStorageFile 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-func-apim-stg-${privateEndpointStorageFileName}'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks/subnets',
        'vnet-apim-cs-rmor2-dev-westeurope',
        'snet-func-apim-stg'
      )
    }
    privateLinkServiceConnections: [
      {
        name: 'filePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['file']
        }
      }
    ]
  }
  dependsOn: [
    name_resource

    storageSubnetDeployment
  ]
}

resource pe_func_apim_stg_privateEndpointStorageTable 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-func-apim-stg-${privateEndpointStorageTableName}'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks/subnets',
        'vnet-apim-cs-rmor2-dev-westeurope',
        'snet-func-apim-stg'
      )
    }
    privateLinkServiceConnections: [
      {
        name: 'tablePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['table']
        }
      }
    ]
  }
  dependsOn: [
    name_resource

    storageSubnetDeployment
  ]
}

resource pe_func_apim_stg_privateEndpointStorageBlob 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-func-apim-stg-${privateEndpointStorageBlobName}'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks/subnets',
        'vnet-apim-cs-rmor2-dev-westeurope',
        'snet-func-apim-stg'
      )
    }
    privateLinkServiceConnections: [
      {
        name: 'blobPrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
  dependsOn: [
    name_resource

    storageSubnetDeployment
  ]
}

resource pe_func_apim_stg_privateEndpointStorageQueue 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-func-apim-stg-${privateEndpointStorageQueueName}'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks/subnets',
        'vnet-apim-cs-rmor2-dev-westeurope',
        'snet-func-apim-stg'
      )
    }
    privateLinkServiceConnections: [
      {
        name: 'queuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['queue']
        }
      }
    ]
  }
  dependsOn: [
    name_resource

    storageSubnetDeployment
  ]
}

resource privateStorageFileDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateStorageFileDnsZoneName
  location: 'global'
  dependsOn: [pe_func_apim_stg_privateEndpointStorageFile]
}

resource pe_func_apim_stg_privateEndpointStorageFileName_privateEndpointStorageFile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: pe_func_apim_stg_privateEndpointStorageFile
  name: privateEndpointStorageFileName
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateStorageFileDnsZone.id
        }
      }
    ]
  }
}

resource privateStorageFileDnsZoneName_privateStorageFileDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateStorageFileDnsZone
  name: '${privateStorageFileDnsZoneName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks',
        'vnet-apim-cs-rmor2-dev-westeurope'
      )
    }
    registrationEnabled: false
  }
  dependsOn: [pe_func_apim_stg_privateEndpointStorageFile]
}

resource privateStorageTableDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateStorageTableDnsZoneName
  location: 'global'
  dependsOn: [pe_func_apim_stg_privateEndpointStorageTable]
}

resource pe_func_apim_stg_privateEndpointStorageTableName_privateEndpointStorageTable 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: pe_func_apim_stg_privateEndpointStorageTable
  name: privateEndpointStorageTableName
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateStorageTableDnsZone.id
        }
      }
    ]
  }
}

resource privateStorageTableDnsZoneName_privateStorageTableDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateStorageTableDnsZone
  name: '${privateStorageTableDnsZoneName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks',
        'vnet-apim-cs-rmor2-dev-westeurope'
      )
    }
    registrationEnabled: false
  }
  dependsOn: [pe_func_apim_stg_privateEndpointStorageTable]
}

resource privateStorageBlobDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'
  dependsOn: [pe_func_apim_stg_privateEndpointStorageBlob]
}

resource pe_func_apim_stg_privateEndpointStorageBlobName_privateEndpointStorageBlob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: pe_func_apim_stg_privateEndpointStorageBlob
  name: privateEndpointStorageBlobName
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateStorageBlobDnsZone.id
        }
      }
    ]
  }
}

resource privateStorageBlobDnsZoneName_privateStorageBlobDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateStorageBlobDnsZone
  name: '${privateStorageBlobDnsZoneName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks',
        'vnet-apim-cs-rmor2-dev-westeurope'
      )
    }
    registrationEnabled: false
  }
  dependsOn: [pe_func_apim_stg_privateEndpointStorageBlob]
}

resource privateStorageQueueDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateStorageQueueDnsZoneName
  location: 'global'
  dependsOn: [pe_func_apim_stg_privateEndpointStorageQueue]
}

resource pe_func_apim_stg_privateEndpointStorageQueueName_privateEndpointStorageQueue 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: pe_func_apim_stg_privateEndpointStorageQueue
  name: privateEndpointStorageQueueName
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateStorageQueueDnsZone.id
        }
      }
    ]
  }
}

resource privateStorageQueueDnsZoneName_privateStorageQueueDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateStorageQueueDnsZone
  name: '${privateStorageQueueDnsZoneName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: resourceId(
        'rg-networking-rmor2-dev-westeurope-001',
        'Microsoft.Network/virtualNetworks',
        'vnet-apim-cs-rmor2-dev-westeurope'
      )
    }
    registrationEnabled: false
  }
  dependsOn: [pe_func_apim_stg_privateEndpointStorageQueue]
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
  }
}
