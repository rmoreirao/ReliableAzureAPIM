
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
param apimVNetName string
param firewallSubnetName string 
param udrApimFirewallName string

var publicIPAddressNameFirewall = 'pip-firewall-${workloadName}-${deploymentEnvironment}-${location}'
var firewallPolicyName = 'fw-policy-${workloadName}-${deploymentEnvironment}-${location}'
var firewallName = 'fw-${workloadName}-${deploymentEnvironment}-${location}'


// Public IP Address for the Firewall

resource pipFw 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: publicIPAddressNameFirewall
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${publicIPAddressNameFirewall}-${uniqueString(resourceGroup().id)}')
    }
  } 
  
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2020-04-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

resource firewallPolicies 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
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
resource firewall 'Microsoft.Network/azureFirewalls@2020-04-01' = {
  name: firewallName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'AzureFirewallIpConfig'
        properties: {
          subnet: json('{"id": "${azureFirewallSubnetId}"}')
          publicIPAddress: {
            id: pipFw.id
          }
        }
      }
    ]
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
  dependsOn: [
    firewallPolicies
  ]
}

resource udrApimFirewall 'Microsoft.Network/routeTables@2023-06-01' = {
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
