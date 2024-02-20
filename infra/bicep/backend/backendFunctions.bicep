//
// Parameters
//

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

@description('Functions Outbound subnet id')
param functiounsOutboundSubnetId string
param functionsInboundPrivateEndpointSubnetid string
param functionsStorageInboundSubnetid string
param vnetName string
param vnetRG string

param location string

//
// Azure Storage
//
var storageAccountName  = toLower(take(replace('stbknd${workloadName}${environment}${location}', '-',''), 24))

var storageAccountSku  = 'Standard_LRS'
var storageAccountKind  = 'StorageV2'
var functionContentShareName = 'func-contents'


var storageAccounts_minTLSVersion = 'TLS1_2'
var privateEndpointStorageAccountQueueName = 'pep-sa-queue-${workloadName}-${environment}-${location}'
var privateEndpointStorageaccountBlobName = 'pep-sa-blob-${workloadName}-${environment}-${location}'
var privateEndpointStorageAccountFileName = 'pep-sa-file-${workloadName}-${environment}-${location}'
var privateEndpointStorageAccountTableName = 'pep-sa-table-${workloadName}-${environment}-${location}'


// Azure Application Service Plan
//
// - name
var appServicePlanFunctionName  = 'plan-func-${workloadName}-${environment}-${location}'

var appServicePlanFunctionSku  = 'EP1' // dev - 'B1'
var appServicePlanFunctionSkuTier  = 'ElasticPremium' // dev - 'Basic'

var functionsAppServiceName = 'func-code-be-${workloadName}-${environment}-${location}'
var functionsAppServiceHostname   = 'func-code-be-${workloadName}-${environment}-${location}.azurewebsites.net'
var functionsAppServiceRepoHostname   = 'func-code-be-${workloadName}-${environment}-${location}.scm.azurewebsites.net'
var functionsAppServiceHostnameBindingName   = 'funccodebe${workloadName}${environment}${location}'
var functionsAppServiceHostnamePrivateEndpointName   = 'pep-func-code-be-${workloadName}-${environment}-${location}'


//
// Definitions
//
// Azure Storage Account
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
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}


module queueStoragePrivateEndpoint './backendnetworking.bicep' = {
  name: privateEndpointStorageAccountQueueName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageAccountQueueName
    // privateDnsZoneName: 'queueDnsZone'
    storageAcountName: storageAccountName
    groupId: 'queue'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: functionsStorageInboundSubnetid
  }
}

module blobStoragePrivateEndpoint './backendnetworking.bicep' = {
  name: privateEndpointStorageaccountBlobName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageaccountBlobName
    storageAcountName: storageAccountName
    groupId: 'blob'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: functionsStorageInboundSubnetid
  }
}

module tableStoragePrivateEndpoint './backendnetworking.bicep' = {
  name: privateEndpointStorageAccountTableName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageAccountTableName
    storageAcountName: storageAccountName
    groupId: 'table'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: functionsStorageInboundSubnetid
  }
}

module fileStoragePrivateEndpoint './backendnetworking.bicep' = {
  name: privateEndpointStorageAccountFileName
  params: {
    location: location
    privateEndpointName: privateEndpointStorageAccountFileName
    storageAcountName: storageAccountName
    groupId: 'file'
    storageAccountId: storageAccount.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: functionsStorageInboundSubnetid
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccount.name}/default/${functionContentShareName}'
}

// Azure Application Service Plan
resource appServicePlanFunction 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: appServicePlanFunctionName
  location: location
  sku: {
    name:  appServicePlanFunctionSku
    tier: appServicePlanFunctionSkuTier
    // size: appServicePlanFunctionSkuSize
    // family: appServicePlanFunctionSkuFamily
    // capacity: appServicePlanFunctionSkuCapacity
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}


resource functionsAppService 'Microsoft.Web/sites@2022-09-01' = {
  name: functionsAppServiceName
  location: location
  kind: 'functionapp,linux'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: functionsAppServiceHostname
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: functionsAppServiceRepoHostname
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanFunction.id
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false

    clientCertEnabled: false
    hostNamesDisabled: false
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    virtualNetworkSubnetId: functiounsOutboundSubnetId
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true

    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: false
      http20Enabled: false
      cors: {
        allowedOrigins: ['https://portal.azure.com']
      }
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
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
        // This is required to connect to the Storage account using the VNET - don't remove it!
        // https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#website_contentovervnet
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionContentShareName
        }
      ]      
    }
  }
  dependsOn: [
    queueStoragePrivateEndpoint
    blobStoragePrivateEndpoint
    tableStoragePrivateEndpoint
    fileStoragePrivateEndpoint
  ]
}

// Hostname binding for Azure Function App (Linux, .NET Core 3.1)
resource functionsAppServiceHostnameBinding 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
  parent: functionsAppService
  name: '${functionsAppServiceName}.azurewebsites.net'
  properties: {
    siteName: functionsAppServiceHostnameBindingName
    hostNameType: 'Verified'
  }
}

resource planNetworkConfig 'Microsoft.Web/sites/networkConfig@2021-01-01' = {
  parent: functionsAppService
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: functiounsOutboundSubnetId
    swiftSupported: true
  }
}

var privateDNSZoneName = 'privatelink.azurewebsites.net'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: functionsAppServiceHostnamePrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: functionsInboundPrivateEndpointSubnetid
    }
    privateLinkServiceConnections: [
      {
        name: functionsAppServiceHostnamePrivateEndpointName
        properties: {
          privateLinkServiceId: functionsAppService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZones
  name: uniqueString(vnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${functionsAppServiceHostname}-azurewebsites-net'
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
  dependsOn: [
    privateDnsZoneLink
  ]
}
