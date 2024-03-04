
{
  '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#'
  contentVersion: '1.0.0.0'
  parameters: {
    location: {
      value: 'westeurope'
    }
    applicationGatewayName: {
      value: 'testappgateway'
    }
    tier: {
      value: 'Standard_v2'
    }
    skuSize: {
      value: 'Standard_v2'
    }
    capacity: {
      value: 1
    }
    subnetName: {
      value: 'snet-apgw-dimt1-dev-westeurope-001'
    }
    zones: {
      value: ['1', '2', '3']
    }
    publicIpAddressName: {
      value: []
    }
    sku: {
      value: []
    }
    allocationMethod: {
      value: []
    }
    ipAddressVersion: {
      value: []
    }
    privateIpAddress: {
      value: []
    }
    autoScaleMaxCapacity: {
      value: 3
    }
  }
}

param location string
param applicationGatewayName string
param tier string
param skuSize string
param capacity int = 2
param subnetName string
param zones array
param publicIpAddressName array
param sku array
param allocationMethod array
param ipAddressVersion array
param privateIpAddress array
param autoScaleMaxCapacity int

var vnetId = '/subscriptions/2d172aeb-b927-43ec-9808-8c9585119364/resourceGroups/rg-apim-networking-dimt1-dev-westeurope-001/providers/Microsoft.Network/virtualNetworks/vnet-apim-dimt1-dev-westeurope'
var publicIPRef = [
  '/subscriptions/2d172aeb-b927-43ec-9808-8c9585119364/resourceGroups/rg-apim-networking-dimt1-dev-westeurope-001/providers/Microsoft.Network/publicIPAddresses/pip-appgw-dimt1-dev-westeurope'
]
var subnetRef = '${vnetId}/subnets/${subnetName}'
var applicationGatewayId = applicationGateway.id

resource applicationGateway 'Microsoft.Network/applicationGateways@2023-02-01' = {
  name: applicationGatewayName
  location: location
  zones: zones
  tags: {}
  properties: {
    sku: {
      name: skuSize
      tier: tier
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        properties: {
          publicIPAddress: {
            id: publicIPRef[0]
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
    ]
    backendAddressPools: [
      {
        name: 'test'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'settings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'listener'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayId}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGatewayId}/frontendPorts/port_80'
          }
          protocol: 'Http'
          sslCertificate: null
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    requestRoutingRules: [
      {
        name: 'testrule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayId}/httpListeners/listener'
          }
          priority: 1
          backendAddressPool: {
            id: '${applicationGatewayId}/backendAddressPools/test'
          }
          backendHttpSettings: {
            id: '${applicationGatewayId}/backendHttpSettingsCollection/settings'
          }
        }
      }
    ]
    routingRules: []
    enableHttp2: true
    sslCertificates: []
    probes: []
    autoscaleConfiguration: {
      minCapacity: capacity
      maxCapacity: autoScaleMaxCapacity
    }
  }
  dependsOn: []
}
