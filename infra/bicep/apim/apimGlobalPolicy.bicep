param apimServiceName string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName
}

resource apiManagementServicePolicy 'Microsoft.ApiManagement/service/policies@2019-01-01' = {
  parent: apiManagementService
  name: 'policy'
  properties: {
    value: './apimConfig/policies/global.xml'
    format: 'xml-link'
  }
}
