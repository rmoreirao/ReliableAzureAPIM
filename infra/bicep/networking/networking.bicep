

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
param location string

param apimVNetNameAddressPrefix string = '10.2.0.0/16'

param bastionAddressPrefix string = '10.2.1.0/24'
param devOpsNameAddressPrefix string = '10.2.2.0/24'
param jumpBoxAddressPrefix string = '10.2.3.0/24'
param appGatewayAddressPrefix string = '10.2.4.0/24'
param functionsInboundAddressPrefix string = '10.2.5.0/24'
param functionsOutboundAddressPrefix string = '10.2.6.0/24'
param apimAddressPrefix string = '10.2.7.0/24'
param firewallAddressPrefix string = '10.2.8.0/24'
param logicAppsOutboundAddressPrefix string = '10.2.10.0/24'
param logicAppsInboundAddressPrefix string = '10.2.11.0/24'
param logicAppsStorageInboundAddressPrefix string = '10.2.12.0/24'

var apimVNetName = 'vnet-apim-${workloadName}-${deploymentEnvironment}-${location}'

var bastionSubnetName = 'AzureBastionSubnet' // Azure Bastion subnet must have AzureBastionSubnet name, not 'snet-bast-${workloadName}-${deploymentEnvironment}-${location}'
var devOpsSubnetName = 'snet-devops-${workloadName}-${deploymentEnvironment}-${location}'
var jumpBoxSubnetName = 'snet-jbox-${workloadName}-${deploymentEnvironment}-${location}-001'
var appGatewaySubnetName = 'snet-apgw-${workloadName}-${deploymentEnvironment}-${location}-001'
var functionsInboundPrivateEndpointSubnetName = 'snet-func-in-${workloadName}-${deploymentEnvironment}-${location}-001'
var functionsOutboundSubnetName = 'snet-func-out-${workloadName}-${deploymentEnvironment}-${location}-001'
var apimSubnetName = 'snet-apim-${workloadName}-${deploymentEnvironment}-${location}-001'
var firewallSubnetName = 'AzureFirewallSubnet'
var bastionName = 'bastion-${workloadName}-${deploymentEnvironment}-${location}'	
var bastionIPConfigName = 'bastionipcfg-${workloadName}-${deploymentEnvironment}-${location}'
var logicAppsInboundPrivateEndpointSubnetName = 'snet-logapps-in-${workloadName}-${deploymentEnvironment}-${location}-001'
var logicAppsOutboundSubnetName = 'snet-logapps-out-${workloadName}-${deploymentEnvironment}-${location}-001'
var logicAppsStorageInboundSubnetName = 'snet-logapps-stg-${workloadName}-${deploymentEnvironment}-${location}-001'

var bastionSNNSG = 'nsg-bast-${workloadName}-${deploymentEnvironment}-${location}'
var devOpsSNNSG = 'nsg-devops-${workloadName}-${deploymentEnvironment}-${location}'
var jumpBoxSNNSG = 'nsg-jbox-${workloadName}-${deploymentEnvironment}-${location}'
var appGatewaySNNSG = 'nsg-apgw-${workloadName}-${deploymentEnvironment}-${location}'
var functionsInboundPrivateEndpointSNNSG = 'nsg-func-in-${workloadName}-${deploymentEnvironment}-${location}'
var functionsOutboundSNNSG = 'nsg-func-out-${workloadName}-${deploymentEnvironment}-${location}'
var logicAppsInboundPrivateEndpointSNNSG = 'nsg-logapps-in-${workloadName}-${deploymentEnvironment}-${location}'
var logicAppsStorageInboundPrivateEndpointSNNSG = 'nsg-logapps-stg-${workloadName}-${deploymentEnvironment}-${location}'
var logicAppsOutboundSNNSG = 'nsg-logapps-out-${workloadName}-${deploymentEnvironment}-${location}'
var apimSNNSG = 'nsg-apim-${workloadName}-${deploymentEnvironment}-${location}'

var publicIPAddressName = 'pip-apimcs-${workloadName}-${deploymentEnvironment}-${location}' // 'publicIp'
var publicIPAddressNameBastion = 'pip-bastion-${workloadName}-${deploymentEnvironment}-${location}'

var udrApimFirewallName = 'udr-apim-fw-${workloadName}-${deploymentEnvironment}-${location}'

// This is created here, and updated in the firewall module because there's a cycle dependency between the firewall and the VNet
resource udrApimFirewall 'Microsoft.Network/routeTables@2023-06-01' = {
  name: udrApimFirewallName
  location: location
  properties: {
    disableBgpRoutePropagation: true
  }
}

// Resources - VNet - SubNets
resource vnetApim 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: apimVNetName
  location: location
  
  properties: {
    addressSpace: {
      addressPrefixes: [
        apimVNetNameAddressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionAddressPrefix
          networkSecurityGroup: {
            id: bastionNSG.id
          }
        }
      }
      {
        name: devOpsSubnetName
        properties: {
          addressPrefix: devOpsNameAddressPrefix
          networkSecurityGroup: {
            id: devOpsNSG.id
          }
        }
      }
      {
        name: jumpBoxSubnetName
        properties: {
          addressPrefix: jumpBoxAddressPrefix
          networkSecurityGroup: {
            id: jumpBoxNSG.id
          }
        }
        
      }
      {
        name: appGatewaySubnetName
        properties: {
          addressPrefix: appGatewayAddressPrefix
          networkSecurityGroup: {
            id: appGatewayNSG.id
          }
        }
      }
      {
        name: functionsInboundPrivateEndpointSubnetName
        properties: {
          addressPrefix: functionsInboundAddressPrefix
          networkSecurityGroup: {
            id: functionsInboundPrivateEndpointNSG.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: functionsOutboundSubnetName
        properties: {
          addressPrefix: functionsOutboundAddressPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: functionsOutboundNSG.id
          }
        }
      }
      {
        name: logicAppsInboundPrivateEndpointSubnetName
        properties: {
          addressPrefix: logicAppsInboundAddressPrefix
          networkSecurityGroup: {
            id: logicAppsInboundPrivateEndpointNSG.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: logicAppsOutboundSubnetName
        properties: {
          addressPrefix: logicAppsOutboundAddressPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: logicAppsOutboundNSG.id
          }
        }
      }
      {
        name: logicAppsStorageInboundSubnetName
        properties: {
          addressPrefix: logicAppsStorageInboundAddressPrefix
          networkSecurityGroup: {
            id: logicAppsStorageInboundPrivateEndpointNSG.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: apimSubnetName
        properties: {
          addressPrefix: apimAddressPrefix
          networkSecurityGroup: {
            id: apimNSG.id
          }
          // this is required due to the Force Tunneling - Azure Firewall
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.EventHub'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                location
              ]
            }
          ]
          routeTable: {
            id: udrApimFirewall.id
          }
        }
      }
      {
        name: firewallSubnetName
        properties: {
          addressPrefix: firewallAddressPrefix
        }
      }
    ]
  }
}

// Network Security Groups (NSG)

// Bastion NSG must have mininal set of rules below
resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: bastionSNNSG
  location: location
  properties: {
    securityRules: [
        {
          name: 'AllowHttpsInbound'
          properties: {
            priority: 120
            protocol: 'Tcp'
            destinationPortRange: '443'
            access: 'Allow'
            direction: 'Inbound'
            sourcePortRange: '*'
            sourceAddressPrefix: 'Internet'
            destinationAddressPrefix: '*'
          }              
        }
        {
          name: 'AllowGatewayManagerInbound'
          properties: {
            priority: 130
            protocol: 'Tcp'
            destinationPortRange: '443'
            access: 'Allow'
            direction: 'Inbound'
            sourcePortRange: '*'
            sourceAddressPrefix: 'GatewayManager'
            destinationAddressPrefix: '*'
          }              
        }
        {
            name: 'AllowAzureLoadBalancerInbound'
            properties: {
              priority: 140
              protocol: 'Tcp'
              destinationPortRange: '443'
              access: 'Allow'
              direction: 'Inbound'
              sourcePortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
            }         
          }     
          {
              name: 'AllowBastionHostCommunicationInbound'
              properties: {
                priority: 150
                protocol: '*'
                destinationPortRanges:[
                  '8080'
                  '5701'                
                ] 
                access: 'Allow'
                direction: 'Inbound'
                sourcePortRange: '*'
                sourceAddressPrefix: 'VirtualNetwork'
                destinationAddressPrefix: 'VirtualNetwork'
              }              
          }                    
          {
            name: 'AllowSshRdpOutbound'
            properties: {
              priority: 100
              protocol: '*'
              destinationPortRanges:[
                '22'
                '3389'
              ]
              access: 'Allow'
              direction: 'Outbound'
              sourcePortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'VirtualNetwork'
            }              
          }       
          {
            name: 'AllowAzureCloudOutbound'
            properties: {
              priority: 110
              protocol: 'Tcp'
              destinationPortRange:'443'              
              access: 'Allow'
              direction: 'Outbound'
              sourcePortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'AzureCloud'
            }              
          }                                                         
          {
            name: 'AllowBastionCommunication'
            properties: {
              priority: 120
              protocol: '*'
              destinationPortRanges: [  
                '8080'
                '5701'
              ]
              access: 'Allow'
              direction: 'Outbound'
              sourcePortRange: '*'
              sourceAddressPrefix: 'VirtualNetwork'
              destinationAddressPrefix: 'VirtualNetwork'
            }              
          }                     
          {
            name: 'AllowGetSessionInformation'
            properties: {
              priority: 130
              protocol: '*'
              destinationPortRange: '80'
              access: 'Allow'
              direction: 'Outbound'
              sourcePortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
            }              
          }                                                                   
    ]
  }
}

resource devOpsNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: devOpsSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}
resource jumpBoxNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: jumpBoxSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource appGatewayNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: appGatewaySNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'HealthProbes'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_TLS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 111
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_AzureLoadBalancer'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}
resource functionsInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: functionsInboundPrivateEndpointSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource functionsOutboundNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: functionsOutboundSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: logicAppsInboundPrivateEndpointSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsStorageInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: logicAppsStorageInboundPrivateEndpointSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsOutboundNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: logicAppsOutboundSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource apimNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: apimSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'apim-mgmt-endpoint-for-portal'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'ApiManagement'
          protocol: 'Tcp'
          destinationPortRange: '3443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'apim-azure-infra-lb'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'AzureLoadBalancer'
          protocol: 'Tcp'
          destinationPortRange: '6390'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'apim-azure-storage'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'apim-azure-sql'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '1433'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'apim-azure-kv'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
    ]
  }
}

// Public IP 
resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${publicIPAddressName}-${uniqueString(resourceGroup().id)}')
    }
  } 
  
}

// Mind the PIP for bastion being Standard SKU, Static IP
resource pipBastion 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: publicIPAddressNameBastion
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${publicIPAddressNameBastion}-${uniqueString(resourceGroup().id)}')
    }
  }  
}

resource bastion 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: bastionName
  location: location 
  properties: {
    ipConfigurations: [
      {
        name: bastionIPConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipBastion.id             
          }
          subnet: {
            id: '${vnetApim.id}/subnets/${bastionSubnetName}' 
          }
        }
      }
    ]
  }
} 

module networking './firewall.bicep' = {
  name: 'networkingfirewallresources'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    deploymentEnvironment: deploymentEnvironment
    location: location
    apimVNetName: apimVNetName
    firewallSubnetName: firewallSubnetName
    udrApimFirewallName: udrApimFirewallName
  }
  dependsOn: [
    vnetApim
  ]
}

// Output section
output apimVNetName string = apimVNetName
output apimVNetId string = vnetApim.id

output bastionSubnetName string = bastionSubnetName  
output devOpsSubnetName string = devOpsSubnetName  
output jumpBoxSubnetName string = jumpBoxSubnetName  
output appGatewaySubnetName string = appGatewaySubnetName  
output functionsInboundPrivateEndpointSubnetName string = functionsInboundPrivateEndpointSubnetName  
output functionsOutboundSubnetName string = functionsOutboundSubnetName  
output apimSubnetName string = apimSubnetName

output bastionSubnetid string = '${vnetApim.id}/subnets/${bastionSubnetName}'  
output CICDAgentSubnetId string = '${vnetApim.id}/subnets/${devOpsSubnetName}'  
output jumpBoxSubnetid string = '${vnetApim.id}/subnets/${jumpBoxSubnetName}'  
output appGatewaySubnetid string = '${vnetApim.id}/subnets/${appGatewaySubnetName}'  
output functionsInboundSubnetid string = '${vnetApim.id}/subnets/${functionsInboundPrivateEndpointSubnetName}'  
output functionsOutboundSubnetid string = '${vnetApim.id}/subnets/${functionsOutboundSubnetName}'
output logicAppsInboundSubnetid string = '${vnetApim.id}/subnets/${logicAppsInboundPrivateEndpointSubnetName}'  
output logicAppsOutboundSubnetid string = '${vnetApim.id}/subnets/${logicAppsOutboundSubnetName}'
output logicAppsStorageInboundSubnetid string = '${vnetApim.id}/subnets/${logicAppsStorageInboundSubnetName}'  
output apimSubnetid string = '${vnetApim.id}/subnets/${apimSubnetName}'  

output publicIp string = pip.id
