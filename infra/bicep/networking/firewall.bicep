import {avalabilityZoneType}  from '../bicepParamTypes.bicep'

param location string

// Parameters
@description('A short name for the workload being deployed')
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])

param deploymentEnvironment string
param sku 'Basic' | 'Standard'
param availabilityZones avalabilityZoneType[]?
param apimVNetName string
param firewallSubnetName string 
param firewallManagementSubnetName string 
param udrApimFirewallName string
param publicIpFirewallId string
param publicIpFirewallMgmtId string?
param deployResources bool

var firewallPolicyName = 'fw-policy-${workloadName}-${deploymentEnvironment}-${location}'
var firewallName = 'fw-${workloadName}-${deploymentEnvironment}-${location}'

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-07-01' = if (deployResources) {
  name: firewallPolicyName
  location: location
  properties: {
    sku: {
      tier: sku
    }
    threatIntelMode: 'Off'
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
  }
}

resource firewallPolicies 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = if (deployResources) {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        name: 'APIM-FW-Rule-Collection'
        priority: 500
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Allow-All-Rule'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: ['*']
            targetUrls: []
            terminateTLS: false
            sourceAddresses: ['*']
            destinationAddresses: []
            sourceIpGroups: []
            httpHeadersToInsert: []
          }
        ]
        
      }
    ]
  }
}

// Azure Firewall

var azureFirewallSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', apimVNetName, firewallSubnetName)
var azureFirewallManagementSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', apimVNetName, firewallManagementSubnetName)

var managementIpConfiguration = publicIpFirewallMgmtId == null ? null : {
  name: 'ManagementIpConfiguration'
  properties: {
    subnet: json('{"id": "${azureFirewallManagementSubnetId}"}')
    publicIPAddress: {
      id: publicIpFirewallMgmtId
    }
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-04-01' = if (deployResources) {
  name: firewallName
  location: location
  zones: availabilityZones    
  properties: {
    sku: {
      tier: sku
    }
    ipConfigurations: [
      {
        name: 'AzureFirewallIpConfig'
        properties: {
          subnet: json('{"id": "${azureFirewallSubnetId}"}')
          publicIPAddress: {
            id: publicIpFirewallId
          }
        }
      }
    ]
    managementIpConfiguration: managementIpConfiguration
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
  dependsOn: [
    firewallPolicies
  ]
}

resource udrApimFirewall 'Microsoft.Network/routeTables@2023-06-01' = if (deployResources) {
  name: udrApimFirewallName
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'route-internet-apim-subnet-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'route-apim-to-internet'
        properties: {
          addressPrefix: 'ApiManagement'
          nextHopType: 'Internet'
          
        }
      }
    ]
  }
}
