
@description('Generated from /subscriptions/68d83f24-120a-47bf-a523-0a42e8e6cad1/resourceGroups/rg-logic-apps/providers/Microsoft.Web/sites/logic-apps-test-apim')
resource logicappstestapim 'Microsoft.Web/sites@2023-01-01' = {
  name: 'logic-apps-test-apim'
  kind: 'functionapp,workflowapp'
  location: 'West Europe'
  tags: {}
  properties: {
    name: 'logic-apps-test-apim'
    webSpace: 'rg-logic-apps-WestEuropewebspace'
    selfLink: 'https://waws-prod-am2-631.api.azurewebsites.windows.net:454/subscriptions/68d83f24-120a-47bf-a523-0a42e8e6cad1/webspaces/rg-logic-apps-WestEuropewebspace/sites/logic-apps-test-apim'
    enabled: true
    adminEnabled: true
    afdEnabled: false
    siteProperties: {
      metadata: null
      properties: [
        {
          name: 'LinuxFxVersion'
          value: ''
        }
        {
          name: 'WindowsFxVersion'
          value: null
        }
      ]
      appSettings: null
    }
    csrs: []
    hostNameSslStates: [
      {
        name: 'logic-apps-test-apim.azurewebsites.net'
        sslState: 'Disabled'
        ipBasedSslState: 'NotConfigured'
        hostType: 'Standard'
      }
      {
        name: 'logic-apps-test-apim.scm.azurewebsites.net'
        sslState: 'Disabled'
        ipBasedSslState: 'NotConfigured'
        hostType: 'Repository'
      }
    ]
    serverFarmId: '/subscriptions/68d83f24-120a-47bf-a523-0a42e8e6cad1/resourceGroups/rg-logic-apps/providers/Microsoft.Web/serverfarms/ASP-rglogicapps-9b5e'
    reserved: false
    isXenon: false
    hyperV: false
    storageRecoveryDefaultState: 'Running'
    contentAvailabilityState: 'Normal'
    runtimeAvailabilityState: 'Normal'
    dnsConfiguration: {}
    vnetRouteAllEnabled: true
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: ''
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    deploymentId: 'logic-apps-test-apim'
    sku: 'WorkflowStandard'
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    ipMode: 'IPv4'
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: '9182816CFAF42440D0446A659ABD7E4281C71D153160389EFE4B0BF4B5BDAE03'
    kind: 'functionapp,workflowapp'
    inboundIpAddress: '20.105.216.22'
    possibleInboundIpAddresses: '20.105.216.22'
    ftpUsername: 'logic-apps-test-apim\\$logic-apps-test-apim'
    ftpsHostName: 'ftps://waws-prod-am2-631.ftp.azurewebsites.windows.net/site/wwwroot'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    siteDisabledReason: 0
    homeStamp: 'waws-prod-am2-631'
    tags: {}
    httpsOnly: true
    endToEndEncryptionEnabled: false
    functionsRuntimeAdminIsolationEnabled: false
    redundancyMode: 'None'
    privateEndpointConnections: [
      {
        id: '/subscriptions/68d83f24-120a-47bf-a523-0a42e8e6cad1/resourceGroups/rg-logic-apps/providers/Microsoft.Web/sites/logic-apps-test-apim/privateEndpointConnections/pe-logic-apps-apim-ee53231f-aefb-4668-a043-04cf80929a77'
        name: 'pe-logic-apps-apim-ee53231f-aefb-4668-a043-04cf80929a77'
        type: 'Microsoft.Web/sites/privateEndpointConnections'
        location: 'West Europe'
        properties: {
          provisioningState: 'Succeeded'
          privateEndpoint: {
            id: '/subscriptions/68d83f24-120a-47bf-a523-0a42e8e6cad1/resourceGroups/rg-logic-apps/providers/Microsoft.Network/privateEndpoints/pe-logic-apps-apim'
          }
          groupIds: null
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: ''
            actionsRequired: 'None'
          }
          ipAddresses: [
            '10.2.0.4'
          ]
        }
      }
    ]
    publicNetworkAccess: 'Disabled'
    eligibleLogCategories: 'WorkflowRuntime,FunctionAppLogs'
    inFlightFeatures: []
    storageAccountRequired: false
    virtualNetworkSubnetId: '/subscriptions/68d83f24-120a-47bf-a523-0a42e8e6cad1/resourceGroups/rg-networking-rmor2-dev-westeurope-001/providers/Microsoft.Network/virtualNetworks/vnet-apim-rmor2-dev-westeurope/subnets/snet-logapps-out-rmor2-dev-westeurope-001'
    keyVaultReferenceIdentity: 'SystemAssigned'
    defaultHostNameScope: 'Global'
    privateLinkIdentifiers: '302045860'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
