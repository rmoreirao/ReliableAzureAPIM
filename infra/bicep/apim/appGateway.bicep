import {avalabilityZoneType}  from '../bicepParamTypes.bicep'

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

@allowed([
  'Standard_v2'
  'WAF_v2'
])
param sku string
param zones avalabilityZoneType[]?
param minCapacity int
param maxCapacity int

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFQDN                string = 'api.example.com'

@description('The location of the Application Gateawy to be created')
param location                      string = resourceGroup().location

@description('The subnet resource id to use for Application Gateway.')
param appGatewaySubnetId            string

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
param appGatewayCertType string



@description('The resource id of the Log Analytics Workspace to be used for diagnostics.')
param logAnalyticsWorkspaceResourceId string

param keyVaultName string
param keyVaultResourceGroupName string

@secure()
param certPassword string  

param deployScriptStorageSubnetId string 
param appGatewayPublicIPAddressId string

// param apimName string
param apimCustomDomainName string

param apimGatewayURL string
param apimDevPortalURL string?
param apimManagementBackendEndURL string?
param deployResources bool

var apimGatewayFQDN = replace(apimGatewayURL, 'https://', '')
var apimDevPortalFQDN = apimDevPortalURL == null ? null : replace(apimDevPortalURL!, 'https://', '')
var apimManagementBackendEndFQDN  = apimManagementBackendEndURL == null ? null : replace(apimManagementBackendEndURL!, 'https://', '')

var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var appGatewayName = 'appgw-${resourceSuffix}'
var appGatewayIdentityId            = 'identity-${appGatewayName}'
var appGatewayDiagnosticSettingsName = 'diag-${appGatewayName}'

// var apimGatewayURL = '${apimName}.azure-api.net'
var apimGatewayCustomHostname = 'api.${apimCustomDomainName}'
// var apimDevPortalURL = '${apimName}.developer.azure-api.net'
var apimDevPortalCustomHostname = 'developer.${apimCustomDomainName}'
// var apimManagementBackendEndURL = '${apimName}.management.azure-api.net'
var apimManagementBackendEndCustomHostname = 'management.${apimCustomDomainName}'

var apiGatewayBackendPool = [
  {
    name: 'apigateway'
    properties: {
      backendAddresses: [
        {
          fqdn: apimGatewayFQDN
        }
      ]
    }
  }
]

var devPortalBackendPool = apimDevPortalFQDN == null ? [] : [
  {
    name: 'devportal'
    properties: {
      backendAddresses: [
        {
          fqdn: apimDevPortalFQDN
        }
      ]
    }
  }
]

var apimManagementBackendPool = apimManagementBackendEndFQDN == null ? [] : [
  {
    name: 'apimanagement'
    properties: {
      backendAddresses: [
        {
          fqdn: apimManagementBackendEndFQDN
        }
      ]
    }
  }
]

var backendAddressPools = concat(apiGatewayBackendPool, devPortalBackendPool, apimManagementBackendPool)

var apiGatewayBackendHttpSettings = [
  {
    name: 'httpsapigateway'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      hostName: apimGatewayFQDN
      pickHostNameFromBackendAddress: false
      requestTimeout: 20
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'apigatewayprobe')
      }
    }
  }
]

var devPortalBackendHttpSettings = apimDevPortalFQDN == null ? [] : [
  {
    name: 'httpsdevportal'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      hostName: apimDevPortalFQDN
      pickHostNameFromBackendAddress: false
      requestTimeout: 20
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'devportalprobe')
      }
    }
  }
]

var apimManagementBackendHttpSettings = apimManagementBackendEndFQDN == null ? [] : [
  {
    name: 'httpsapimanagement'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      hostName: apimManagementBackendEndFQDN
      pickHostNameFromBackendAddress: false
      requestTimeout: 20
      probe: {
        id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'apimanagementprobe')
      }
    }
  }
]

var backendHttpSettingsCollection = concat(apiGatewayBackendHttpSettings, devPortalBackendHttpSettings, apimManagementBackendHttpSettings)

var apimGatewayHttpListener = [
  {
    name: 'httpsapigateway'
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
      hostName: apimGatewayCustomHostname
      hostnames: []
      requireServerNameIndication: true
    }
  }
]

var devPortalHttpListener = apimDevPortalFQDN == null ? [] : [
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
      hostName: apimDevPortalCustomHostname
      hostnames: []
      requireServerNameIndication: true
    }
  }
]

var apimManagementHttpListener = apimManagementBackendEndFQDN == null ? [] : [
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
      hostName: apimManagementBackendEndCustomHostname
      hostnames: []
      requireServerNameIndication: true
    }
  }
]

var httpListeners = concat(apimGatewayHttpListener, devPortalHttpListener, apimManagementHttpListener)

var apiGatewayRequestRoutingRule = [
  {
    name: 'apigateway'
    properties: {
      ruleType: 'Basic'
      httpListener: {
        id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'httpsapigateway')
      }
      backendAddressPool: {
        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'apigateway')
      }
      backendHttpSettings: {
        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'httpsapigateway')
      }
    }
  }
]

var devPortalRequestRoutingRule = apimDevPortalFQDN == null ? [] : [
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
]

var apimManagementRequestRoutingRule = apimManagementBackendEndFQDN == null ? [] : [
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

var requestRoutingRules = concat(apiGatewayRequestRoutingRule, devPortalRequestRoutingRule, apimManagementRequestRoutingRule)

var apiGatewayProbe = [
  {
    name: 'apigatewayprobe'
    properties: {
      protocol: 'Https'
      host: apimGatewayFQDN
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
]

var devPortalProbe = apimDevPortalFQDN == null ? [] : [
  {
    name: 'devportalprobe'
    properties: {
      protocol: 'Https'
      host: apimDevPortalFQDN
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
]

var apimManagementProbe = apimManagementBackendEndFQDN == null ? [] : [
  {
    name: 'apimanagementprobe'
    properties: {
      protocol: 'Https'
      host: apimManagementBackendEndFQDN
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

var probes = concat(apiGatewayProbe, devPortalProbe, apimManagementProbe)

resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:     appGatewayIdentityId
  location: location
}


module kvRoleAssignmentsCert 'kvAppRoleAssignment.bicep' = if (deployResources) {
  name: 'kvRoleAssignmentsCert${workloadName}${environment}${location}'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    principalId: appGatewayIdentity.properties.principalId
    // Key Vault Certificates Officer
    roleId: 'a4417e6f-fecd-4de8-b567-7b0420556985'
  }
}

module kvRoleAssignmentsSecret 'kvAppRoleAssignment.bicep' = if (deployResources) {
  name: 'kvRoleAssignmentsSecret${workloadName}${environment}${location}'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    principalId: appGatewayIdentity.properties.principalId
    // Key Vault Secrets User
    roleId: '4633458b-17de-408a-b874-0445c86b69e6'
  }
  dependsOn: [
    kvRoleAssignmentsCert
  ]
}


module apiGatewayCertificate './appGatewayCertificate.bicep' = {
  name: 'certificate${resourceSuffix}'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    managedIdentity: appGatewayIdentity
    keyVaultName: keyVaultName
    location: location
    appGatewayFQDN: appGatewayFQDN
    appGatewayCertType: appGatewayCertType
    certPassword: certPassword
    keyVaultRG: keyVaultResourceGroupName
    deployScriptStorageSubnetId: deployScriptStorageSubnetId
    environment: environment
    workloadName: workloadName
    deployResources: deployResources
  }
}

// This is only supported for WAF_v2
var webApplicationFirewallConfiguration = sku == 'WAF_v2' ? {
  enabled: true
  firewallMode: 'Prevention'
  ruleSetType: 'OWASP'
  ruleSetVersion: '3.0'
  disabledRuleGroups: []
  requestBodyCheck: true
  maxRequestBodySizeInKb: 128
  fileUploadLimitInMb: 100
} : null

resource appGateway 'Microsoft.Network/applicationGateways@2019-09-01' = if (deployResources) {
  name: appGatewayName
  location: location
  dependsOn: [
    apiGatewayCertificate
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appGatewayIdentity.id}': {}
    }
  }
  zones: zones
  properties: {
    sku: {
      name: sku
      tier: sku
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
          keyVaultSecretId:  apiGatewayCertificate.outputs.secretUriWithVersion
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
            id: appGatewayPublicIPAddressId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    httpListeners: httpListeners
    urlPathMaps: []
    requestRoutingRules: requestRoutingRules
    probes: probes
    rewriteRuleSets: []
    redirectConfigurations: []
    webApplicationFirewallConfiguration: webApplicationFirewallConfiguration
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
  }
}

@description('Upsert the diagnostic settings associated with the application gateway.')
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (deployResources) {
  name: appGatewayDiagnosticSettingsName
  scope: appGateway
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output certificateSecretUriWithoutVersion string = apiGatewayCertificate.outputs.secretUriWithoutVersion
