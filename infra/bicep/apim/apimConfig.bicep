param apimServiceName string

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

  resource echoAPI 'apis' = {
    name: 'echo-api-config'
    properties: {
      displayName: 'Echo API - Config'
      apiRevision: '1'
      subscriptionRequired: false
      serviceUrl: 'http://echoapi.cloudapp.net/api'
      path: 'echo'
      protocols: ['https']
      subscriptionKeyParameterNames: {
        header: 'Ocp-Apim-Subscription-Key'
        query: 'subscription-key'
      }
      isCurrent: true
    }

    resource createResource 'operations' = {
      name: 'createResource'
      properties: {
        displayName: 'Create resource'
        method: 'POST'
        urlTemplate: '/resource'
        templateParameters: []
        description: 'A demonstration of a POST call based on the echo backend above. The request body is expected to contain JSON-formatted data (see example below). A policy is used to automatically transform any request sent in JSON directly to XML. In a real-world scenario this could be used to enable modern clients to speak to a legacy backend.'
        request: {
          queryParameters: []
          headers: []
          representations: [
            {
              contentType: 'application/json'
              examples: {
                default: {
                  value: '{\r\n\t"vehicleType": "train",\r\n\t"maxSpeed": 125,\r\n\t"avgSpeed": 90,\r\n\t"speedUnit": "mph"\r\n}'
                }
              }
            }
          ]
        }
        responses: [
          {
            statusCode: 200
            representations: []
            headers: []
          }
        ]
      }

      resource createResourcePolicy 'policies' = {
        name: 'createResourcePolicy'
        properties: {
          value: loadTextContent('apimConfig/policies/echoAPI/createResource.xml')
          format: 'xml'
        }
      }
    }

    resource modifyResource 'operations' = {
      name: 'modifyResource'
      properties: {
        displayName: 'Modify Resource'
        method: 'PUT'
        urlTemplate: '/resource'
        templateParameters: []
        description: 'A demonstration of a PUT call handled by the same "echo" backend as above. You can now specify a request body in addition to headers and it will be returned as well.'
        responses: [
          {
            statusCode: 200
            representations: []
            headers: []
          }
        ]
      }
    }

    resource removeResource 'operations' = {
      name: 'removeResource'
      properties: {
        displayName: 'Remove Resource'
        method: 'DELETE'
        urlTemplate: '/resource'
        templateParameters: []
        description: 'A demonstration of a DELETE call handled by the same "echo" backend as above. You can now specify a request body in addition to headers and it will be returned as well.'
        responses: [
          {
            statusCode: 200
            representations: []
            headers: []
          }
        ]
      }
    }

    resource retrieveHeaderOnly 'operations' = {
      name: 'retrieve-header-only'
      properties: {
        displayName: 'Retrieve header only'
        method: 'HEAD'
        urlTemplate: '/resource'
        templateParameters: []
        description: 'The HEAD operation returns only headers. In this demonstration a policy is used to set additional headers when the response is returned and to enable JSONP.'
        responses: [
          {
            statusCode: 200
            representations: []
            headers: []
          }
        ]
      }

      resource retrieveHeaderOnlyPolicy 'policies' = {
        name: 'retrieve-header-onlyPolicy'
        properties: {
          value: loadTextContent('apimConfig/policies/echoAPI/retrieveHeaderOnly.xml')
          format: 'xml'
        }
      }
    }
  }
}
