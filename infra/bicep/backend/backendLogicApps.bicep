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
param location string

param logicAppsOutboundSubnetId string
param logicAppsInboundPrivateEndpointSubnetid string
param storageAccountName string
param backendPrivateDnsZoneId string

var logicAppsContentShareName = 'logic-apps-contents'

var appServicePlanLogicAppsName  = 'plan-logapps-${workloadName}-${environment}-${location}'

var appServicePlanLogicAppsSku  = 'WS1'
var appServicePlanLogicAppsSkuTier  = 'WorkflowStandard'

var logicAppsAppServiceName = 'logapps-${workloadName}-${environment}-${location}'
var logicAppsAppServiceHostname   = 'logapps-${workloadName}-${environment}-${location}.azurewebsites.net'
var logicAppsAppServiceRepoHostname   = 'logapps-${workloadName}-${environment}-${location}.scm.azurewebsites.net'
var logicAppsInboundPrivateEndpointName   = 'pep-logapps-${workloadName}-${environment}-${location}'

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccountName}/default/${logicAppsContentShareName}'
}


// Azure Application Service Plan
resource appServicePlanFunction 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanLogicAppsName
  location: location
  sku: {
    name:  appServicePlanLogicAppsSku
    tier: appServicePlanLogicAppsSkuTier
  }
  kind: 'windows'
  properties: {
    zoneRedundant: true
  }
}

// retrieve existing storage account with name storageAccountName
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource logicApp 'Microsoft.Web/sites@2022-09-01' = {
  name: logicAppsAppServiceName
  location: location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        // This is required to connect to the Storage account using the VNET - don't remove it!
        // https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#website_contentovervnet
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: logicAppsContentShareName
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
      ]      
      cors: {
        allowedOrigins: ['https://portal.azure.com']
      }
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      vnetPrivatePortsCount: 2
      netFrameworkVersion: 'v6.0'
      numberOfWorkers: 1
      linuxFxVersion: ''
      alwaysOn: false
      http20Enabled: false      
    }
    enabled: true
    hostNameSslStates: [
      {
        name: logicAppsAppServiceHostname
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: logicAppsAppServiceRepoHostname
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanFunction.id
    clientAffinityEnabled: false
    httpsOnly: true
    redundancyMode: 'None'
    virtualNetworkSubnetId: logicAppsOutboundSubnetId
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true
    storageAccountRequired: false
  }

  dependsOn: [
    fileShare
  ]
}

resource planNetworkConfig 'Microsoft.Web/sites/networkConfig@2021-01-01' = {
  parent: logicApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: logicAppsOutboundSubnetId
    swiftSupported: true
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: logicAppsInboundPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: logicAppsInboundPrivateEndpointSubnetid
    }
    privateLinkServiceConnections: [
      {
        name: logicAppsInboundPrivateEndpointName
        properties: {
          privateLinkServiceId: logicApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${logicAppsAppServiceHostname}-azurewebsites-net'
        properties: {
          privateDnsZoneId: backendPrivateDnsZoneId
        }
      }
    ]
  }
  // dependsOn: [
  //   privateDnsZoneLink
  // ]
}


