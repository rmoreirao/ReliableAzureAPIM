param apimServiceName string
param developerPortalURL string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName

  resource apimServiceNameNamedValue 'namedValues' = {
    name: 'apimServiceName'

    properties: {
      displayName: 'apimServiceName'
      value: apimServiceName
      secret: false
    }
  }

  resource developerPortalURLNamedValue 'namedValues' = {
    name: 'developerPortalURL'

    properties: {
      displayName: 'developerPortalURL'
      value: developerPortalURL
      secret: false
    }
  }
  
  resource globalPolicy 'policies' = {
    name: 'policy'
    dependsOn: [
      apimServiceNameNamedValue
    ]
    properties: {
      value: loadTextContent('apimConfig/policies/global.xml')
      format: 'xml'
    }
  }
}
