/*
 * Input parameters
*/
@description('The name of the Application Gateawy to be created.')
param appGatewayName                string

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFQDN                string = 'api.example.com'

@description('The location of the Application Gateawy to be created')
param location                      string = resourceGroup().location

@description('The subnet resource id to use for Application Gateway.')
param appGatewaySubnetId            string

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
param appGatewayCertType string

@description('The backend URL of the APIM.')
param apimBackendEndFQDN         string = 'apim-example.azure-api.net'

@description('The backend URL of the APIM Deprecated Dev Portal.')
param oldDevPortalBackendEndFQDN         string = 'apim-rmor-dev-westeurope-001.portal.azure-api.net'

@description('The backend URL of the Developer Portal.')
param devPortalBackendEndFQDN         string = 'apim-rmor-dev-westeurope-001.developer.azure-api.net'

@description('The backend URL of the APIM Management.')
param managementBackendEndFQDN         string = 'apim-rmor-dev-westeurope-001.management.azure-api.net'

param keyVaultName                  string
param keyVaultResourceGroupName     string

@secure()
param certPassword                  string  

var appGatewayPrimaryPip            = 'pip-${appGatewayName}'
var appGatewayIdentityId            = 'identity-${appGatewayName}'

resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:     appGatewayIdentityId
  location: location
}

module certificate './modules/certificate.bicep' = {
  name: 'certificate'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    managedIdentity:    appGatewayIdentity
    keyVaultName:       keyVaultName
    location:           location
    appGatewayFQDN:     appGatewayFQDN
    appGatewayCertType: appGatewayCertType
    certPassword:       certPassword
  }
}

resource appGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2019-09-01' = {
  name: appGatewayPrimaryPip
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource appGatewayName_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: appGatewayName
  location: location
  dependsOn: [
    certificate
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appGatewayIdentity.id}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appGatewaySubnetId
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: appGatewayFQDN
        properties: {
          keyVaultSecretId:  certificate.outputs.secretUri
        }
      }
    ]
    sslPolicy: {
      minProtocolVersion: 'TLSv1_2'
      policyType: 'Custom'
      cipherSuites: [        
         'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
         'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
         'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
         'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
         'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
         'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384'
         'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
         'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'
      ]      
    }    
    trustedRootCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: appGatewayPublicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'apim'
        properties: {
          backendAddresses: [
            {
              fqdn: apimBackendEndFQDN
            }
          ]
        }
      }
      {
        name: 'devportalold'
        properties: {
          backendAddresses: [
            {
              fqdn: oldDevPortalBackendEndFQDN
            }
          ]
        }
      }
      {
        name: 'devportal'
        properties: {
          backendAddresses: [
            {
              fqdn: devPortalBackendEndFQDN
            }
          ]
        }
      }
      {
        name: 'apimanagement'
        properties: {
          backendAddresses: [
            {
              fqdn: managementBackendEndFQDN
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'default'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
        }
      }
      {
        name: 'https'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: apimBackendEndFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'apimprobe')
          }
        }
      }
      {
        name: 'httpsdevportalold'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: oldDevPortalBackendEndFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'devportaloldprobe')
          }
        }
      }
      {
        name: 'httpsdevportal'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: devPortalBackendEndFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'devportalprobe')
          }
        }
      }
      {
        name: 'httpsapimanagement'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: managementBackendEndFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'apimanagementprobe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'default'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostnames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, appGatewayFQDN)
          }
          // TODO: to change to the FQDN of the APIM
          hostName: 'api.rmoreirao.net'
          hostnames: []
          requireServerNameIndication: true
        }
      }
      {
        name: 'httpsdevportalold'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, appGatewayFQDN)
          }
          // TODO: To be replaced with the FQDN of the old developer portal
          hostName: 'devportalold.rmoreirao.net'
          hostnames: []
          requireServerNameIndication: true
        }
      }
      {
        name: 'httpsdevportal'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, appGatewayFQDN)
          }
          // TODO: To be replaced with the FQDN of the old developer portal
          hostName: 'devportal.rmoreirao.net'
          hostnames: []
          requireServerNameIndication: true
        }
      }
      {
        name: 'httpsapimanagement'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, appGatewayFQDN)
          }
          // TODO: To be replaced with the FQDN of the management endpoint of the APIM
          hostName: 'management.rmoreirao.net'
          hostnames: []
          requireServerNameIndication: true
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'apim'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'https')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'apim')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'https')
          }
        }
      }
      {
        name: 'devportalold'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'httpsdevportalold')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'devportalold')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'httpsdevportalold')
          }
        }
      }
      {
        name: 'devportal'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'httpsdevportal')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'devportal')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'httpsdevportal')
          }
        }
      }
      {
        name: 'apimanagement'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'httpsapimanagement')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'apimanagement')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'httpsapimanagement')
          }
        }
      }
    ]
    probes: [
      {
        name: 'apimprobe'
        properties: {
          protocol: 'Https'
          host: apimBackendEndFQDN
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'devportaloldprobe'
        properties: {
          protocol: 'Https'
          host: oldDevPortalBackendEndFQDN
          path: '/signin'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'devportalprobe'
        properties: {
          protocol: 'Https'
          host: devPortalBackendEndFQDN
          path: '/signin-sso'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'apimanagementprobe'
        properties: {
          protocol: 'Https'
          host: managementBackendEndFQDN
          path: '/ServiceStatus'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
      disabledRuleGroups: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 3
    }
  }
}
