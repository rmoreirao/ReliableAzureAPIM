import {vNetRegionalSettingsType} from '../bicepParamTypes.bicep'

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

param vNetSettings vNetRegionalSettingsType

var apimVNetName = 'vnet-apim-${workloadName}-${deploymentEnvironment}-${location}'

var bastionSubnetName = 'AzureBastionSubnet' // Azure Bastion subnet must have AzureBastionSubnet name, not 'snet-bast-${workloadName}-${deploymentEnvironment}-${location}'
var devOpsSubnetName = 'snet-devops-${workloadName}-${deploymentEnvironment}-${location}'
var jumpBoxSubnetName = 'snet-jbox-${workloadName}-${deploymentEnvironment}-${location}-001'
var appGatewaySubnetName = 'snet-apgw-${workloadName}-${deploymentEnvironment}-${location}-001'
var functionsInboundPrivateEndpointSubnetName = 'snet-func-in-${workloadName}-${deploymentEnvironment}-${location}-001'
var functionsOutboundSubnetName = 'snet-func-out-${workloadName}-${deploymentEnvironment}-${location}-001'
var apimSubnetName = 'snet-apim-${workloadName}-${deploymentEnvironment}-${location}-001'
var firewallSubnetName = 'AzureFirewallSubnet'
var firewallManagementSubnetName = 'AzureFirewallManagementSubnet'
var deployScriptStorageSubnetName = 'dscript-${workloadName}-${deploymentEnvironment}-${location}'	

var logicAppsInboundPrivateEndpointSubnetName = 'snet-logapps-in-${workloadName}-${deploymentEnvironment}-${location}-001'
var logicAppsOutboundSubnetName = 'snet-logapps-out-${workloadName}-${deploymentEnvironment}-${location}-001'
var logicAppsStorageInboundSubnetName = 'snet-logapps-stg-${workloadName}-${deploymentEnvironment}-${location}-001'

var keyVaultInboundPrivateEndpointSubnetName = 'snet-kv-in-${workloadName}-${deploymentEnvironment}-${location}-001'

var bastionNSGName = 'nsg-bast-${workloadName}-${deploymentEnvironment}-${location}'
var devOpsNSGName = 'nsg-devops-${workloadName}-${deploymentEnvironment}-${location}'
var jumpBoxNSGName = 'nsg-jbox-${workloadName}-${deploymentEnvironment}-${location}'
var appGatewayNSGName = 'nsg-apgw-${workloadName}-${deploymentEnvironment}-${location}'
var functionsInboundPrivateEndpointNSGName = 'nsg-func-in-${workloadName}-${deploymentEnvironment}-${location}'
var functionsOutboundNSGName = 'nsg-func-out-${workloadName}-${deploymentEnvironment}-${location}'
var logicAppsInboundPrivateEndpointNSGName = 'nsg-logapps-in-${workloadName}-${deploymentEnvironment}-${location}'
var logicAppsStorageInboundPrivateEndpointNSGName = 'nsg-logapps-stg-${workloadName}-${deploymentEnvironment}-${location}'
var logicAppsOutboundNSGName = 'nsg-logapps-out-${workloadName}-${deploymentEnvironment}-${location}'
var keyVaultInboundPrivateEndpointNSGName = 'nsg-kv-${workloadName}-${deploymentEnvironment}-${location}'
var apimSNNSG = 'nsg-apim-${workloadName}-${deploymentEnvironment}-${location}'

var udrApimFirewallName = 'udr-apim-fw-${workloadName}-${deploymentEnvironment}-${location}'

// This is created here, and updated in the firewall module because there's a cycle dependency between the firewall and the VNet
resource udrApimFirewall 'Microsoft.Network/routeTables@2023-06-01' = {
  name: udrApimFirewallName
  location: location
  properties: {
    disableBgpRoutePropagation: true
  }
}


// // Network Security Groups (NSG)

// Bastion NSG must have mininal set of rules below
resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?bastionAddressPrefix != null) {
  name: bastionNSGName
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

resource devOpsNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?devOpsAgentAddressPrefix != null) {
  name: devOpsNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}
resource jumpBoxNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?jumpBoxAddressPrefix != null) {
  name: jumpBoxNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource appGatewayNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?appGatewayAddressPrefix != null) {
  name: appGatewayNSGName
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
resource functionsInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?functionsInboundAddressPrefix != null) {
  name: functionsInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource functionsOutboundNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?functionsOutboundAddressPrefix != null) {
  name: functionsOutboundNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?logicAppsInboundAddressPrefix != null) {
  name: logicAppsInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsStorageInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?logicAppsStorageInboundAddressPrefix != null) {
  name: logicAppsStorageInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsOutboundNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?logicAppsOutboundAddressPrefix != null) {
  name: logicAppsOutboundNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource keyVaultInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?keyVaultInboundPrivateEndpointAddressPrefix != null) {
  name: keyVaultInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource apimNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (vNetSettings.?apimAddressPrefix != null) {
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

var bastionSubnet = vNetSettings.?bastionAddressPrefix == null ? [] : [{
  name: bastionSubnetName
  properties: {
    addressPrefix: vNetSettings.bastionAddressPrefix
    networkSecurityGroup: {
      id: bastionNSG.id
    }
  }
}]

var devOpsSubnet = vNetSettings.?devOpsAgentAddressPrefix == null ? [] : [{
  name: devOpsSubnetName
  properties: {
    addressPrefix: vNetSettings.devOpsAgentAddressPrefix
    networkSecurityGroup: {
      id: devOpsNSG.id
    }
  }
}]

var jumpBoxSubnet = vNetSettings.?jumpBoxAddressPrefix == null ? [] : [{
  name: jumpBoxSubnetName
  properties: {
    addressPrefix: vNetSettings.jumpBoxAddressPrefix
    networkSecurityGroup: {
      id: jumpBoxNSG.id
    }
  }
}]

var appGatewaySubnet = vNetSettings.?appGatewayAddressPrefix == null ? [] : [{
  name: appGatewaySubnetName
  properties: {
    addressPrefix: vNetSettings.appGatewayAddressPrefix
    networkSecurityGroup: {
      id: appGatewayNSG.id
    }
  }
}]

var functionsInboundPrivateEndpointSubnet = vNetSettings.?functionsInboundAddressPrefix == null ? [] : [{
  name: functionsInboundPrivateEndpointSubnetName
  properties: {
    addressPrefix: vNetSettings.functionsInboundAddressPrefix
    networkSecurityGroup: {
      id: functionsInboundPrivateEndpointNSG.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
  }
}]

var functionsOutboundSubnet = vNetSettings.?functionsOutboundAddressPrefix == null ? [] : [{
  name: functionsOutboundSubnetName
  properties: {
    addressPrefix: vNetSettings.functionsOutboundAddressPrefix
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
}]

var logicAppsInboundPrivateEndpointSubnet = vNetSettings.?logicAppsInboundAddressPrefix == null ? [] : [{
  name: logicAppsInboundPrivateEndpointSubnetName
  properties: {
    addressPrefix: vNetSettings.logicAppsInboundAddressPrefix
    networkSecurityGroup: {
      id: logicAppsInboundPrivateEndpointNSG.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
  }
}]

var keyVaultInboundPrivateEndpointSubnet = vNetSettings.?keyVaultInboundPrivateEndpointAddressPrefix == null ? [] : [{
  name: keyVaultInboundPrivateEndpointSubnetName
  properties: {
    addressPrefix: vNetSettings.keyVaultInboundPrivateEndpointAddressPrefix
    networkSecurityGroup: {
      id: keyVaultInboundPrivateEndpointNSG.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
  }
}]

var deployScriptStorageSubnet = vNetSettings.?deployScriptStorageSubnetAddressPrefix == null ? [] : [{
  name: deployScriptStorageSubnetName
  properties: {
    addressPrefix: vNetSettings.deployScriptStorageSubnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
    delegations: [
      {
        name: 'Microsoft.ContainerInstance.containerGroups'
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
      }
    ]
  }
}]

var logicAppsOutboundSubnet = vNetSettings.?logicAppsOutboundAddressPrefix == null ? [] : [{
  name: logicAppsOutboundSubnetName
  properties: {
    addressPrefix: vNetSettings.logicAppsOutboundAddressPrefix
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
}]

var logicAppsStorageInboundSubnet = vNetSettings.?logicAppsStorageInboundAddressPrefix == null ? [] : [{
  name: logicAppsStorageInboundSubnetName
  properties: {
    addressPrefix: vNetSettings.logicAppsStorageInboundAddressPrefix
    networkSecurityGroup: {
      id: logicAppsStorageInboundPrivateEndpointNSG.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
  }
}]

var apimSubnetUdr = vNetSettings.?firewallAddressPrefix == null ? {} : {
  id: udrApimFirewall.id
}

var apimSubnet = vNetSettings.?apimAddressPrefix == null ? [] : [{
  name: apimSubnetName
  properties: {
    addressPrefix: vNetSettings.apimAddressPrefix
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
    routeTable: apimSubnetUdr
  }
}]

var firewallSubnet = vNetSettings.?firewallAddressPrefix == null ? [] : [{
  name: firewallSubnetName
  properties: {
    addressPrefix: vNetSettings.firewallAddressPrefix
  }
}]

var firewallManagementSubnet = vNetSettings.?firewallManagementAddressPrefix == null ? [] : [{
  name: firewallManagementSubnetName
  properties: {
    addressPrefix: vNetSettings.firewallManagementAddressPrefix
  }
}]

var allSubnets = concat(bastionSubnet, devOpsSubnet, jumpBoxSubnet, appGatewaySubnet, functionsInboundPrivateEndpointSubnet, functionsOutboundSubnet, logicAppsInboundPrivateEndpointSubnet, deployScriptStorageSubnet, logicAppsOutboundSubnet, logicAppsStorageInboundSubnet, keyVaultInboundPrivateEndpointSubnet, apimSubnet, firewallSubnet, firewallManagementSubnet)

// Resources - VNet - SubNets
resource vnetApim 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: apimVNetName
  location: location
  
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetSettings.apimVNetNameAddressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: allSubnets
  }
}



// // Output section
// output apimVNetName string = apimVNetName
// output apimVNetId string = vnetApim.id

// output firewallSubnetName string = firewallSubnetName
// output firewallManagementSubnetName string = firewallManagementSubnetName

// output bastionSubnetid string? = vNetSettings.bastionAddressPrefix != null ? '${vnetApim.id}/subnets/${bastionSubnetName}' : null
// output devOpsAgentSubnetId string? = vNetSettings.?devOpsAgentAddressPrefix != null ? '${vnetApim.id}/subnets/${devOpsSubnetName}'  : null
// output jumpBoxSubnetid string? = vNetSettings.?jumpBoxAddressPrefix != null ? '${vnetApim.id}/subnets/${jumpBoxSubnetName}'  : null
// output appGatewaySubnetid string? = vNetSettings.?appGatewayAddressPrefix != null ? '${vnetApim.id}/subnets/${appGatewaySubnetName}'  : null
// output functionsInboundSubnetid string? = vNetSettings.?functionsInboundAddressPrefix != null ?'${vnetApim.id}/subnets/${functionsInboundPrivateEndpointSubnetName}'  : null
// output functionsOutboundSubnetid string? = vNetSettings.?functionsOutboundAddressPrefix != null ?'${vnetApim.id}/subnets/${functionsOutboundSubnetName}': null
// output logicAppsInboundSubnetid string? = vNetSettings.?logicAppsInboundAddressPrefix != null ?'${vnetApim.id}/subnets/${logicAppsInboundPrivateEndpointSubnetName}'  : null
// output logicAppsOutboundSubnetid string? = vNetSettings.?logicAppsOutboundAddressPrefix != null ?'${vnetApim.id}/subnets/${logicAppsOutboundSubnetName}': null
// output logicAppsStorageInboundSubnetid string? = vNetSettings.?logicAppsStorageInboundAddressPrefix != null ?'${vnetApim.id}/subnets/${logicAppsStorageInboundSubnetName}'  : null
// output keyVaultStorageInboundSubnetid string? = vNetSettings.?keyVaultInboundPrivateEndpointAddressPrefix != null ?'${vnetApim.id}/subnets/${keyVaultInboundPrivateEndpointSubnetName}': null
// output deployScriptStorageSubnetId string? = vNetSettings.?deployScriptStorageSubnetAddressPrefix != null ?'${vnetApim.id}/subnets/${deployScriptStorageSubnetName}': null
// output apimSubnetid string = '${vnetApim.id}/subnets/${apimSubnetName}'
// output firewallSubnetid string? = vNetSettings.?firewallAddressPrefix != null ?'${vnetApim.id}/subnets/${firewallSubnetName}': null
// output udrApimFirewallName string? = vNetSettings.?firewallAddressPrefix != null ? udrApimFirewallName: null


// Output section
output apimVNetName string = apimVNetName
output apimVNetId string = vnetApim.id

output firewallSubnetName string = firewallSubnetName
output firewallManagementSubnetName string = firewallManagementSubnetName

// output bastionSubnetid string =  '${vnetApim.id}/subnets/${bastionSubnetName}'  
// output devOpsAgentSubnetId string = '${vnetApim.id}/subnets/${devOpsSubnetName}'  
// // output jumpBoxSubnetid string = '${vnetApim.id}/subnets/${jumpBoxSubnetName}'  
// output appGatewaySubnetid string = '${vnetApim.id}/subnets/${appGatewaySubnetName}'  
// output functionsInboundSubnetid string = '${vnetApim.id}/subnets/${functionsInboundPrivateEndpointSubnetName}'  
// output functionsOutboundSubnetid string = '${vnetApim.id}/subnets/${functionsOutboundSubnetName}'
// output logicAppsInboundSubnetid string = '${vnetApim.id}/subnets/${logicAppsInboundPrivateEndpointSubnetName}'  
// output logicAppsOutboundSubnetid string = '${vnetApim.id}/subnets/${logicAppsOutboundSubnetName}'
// output logicAppsStorageInboundSubnetid string = '${vnetApim.id}/subnets/${logicAppsStorageInboundSubnetName}'  
// // output keyVaultStorageInboundSubnetid string = '${vnetApim.id}/subnets/${keyVaultInboundPrivateEndpointSubnetName}'
// output deployScriptStorageSubnetId string = '${vnetApim.id}/subnets/${deployScriptStorageSubnetName}'
// output apimSubnetid string = '${vnetApim.id}/subnets/${apimSubnetName}'  
// output firewallSubnetid string = '${vnetApim.id}/subnets/${firewallSubnetName}'
// output udrApimFirewallName string = udrApimFirewallName

output apimSubnetid string = '${vnetApim.id}/subnets/${apimSubnetName}'
output appGatewaySubnetid string = '${vnetApim.id}/subnets/${appGatewaySubnetName}'
output keyVaultStorageInboundSubnetid string? = vNetSettings.?keyVaultInboundPrivateEndpointAddressPrefix != null ?'${vnetApim.id}/subnets/${keyVaultInboundPrivateEndpointSubnetName}': null
output firewallSubnetid string? = vNetSettings.?firewallAddressPrefix != null ?'${vnetApim.id}/subnets/${firewallSubnetName}': null
output udrApimFirewallName string? = vNetSettings.?firewallAddressPrefix != null ? udrApimFirewallName: null

output bastionSubnetid string? = vNetSettings.?bastionAddressPrefix != null ? '${vnetApim.id}/subnets/${bastionSubnetName}' : null
output devOpsAgentSubnetId string? = vNetSettings.?devOpsAgentAddressPrefix != null ? '${vnetApim.id}/subnets/${devOpsSubnetName}'  : null
output jumpBoxSubnetid string? = vNetSettings.?jumpBoxAddressPrefix != null ? '${vnetApim.id}/subnets/${jumpBoxSubnetName}'  : null
output functionsInboundSubnetid string? = vNetSettings.?functionsInboundAddressPrefix != null ?'${vnetApim.id}/subnets/${functionsInboundPrivateEndpointSubnetName}'  : null
output functionsOutboundSubnetid string? = vNetSettings.?functionsOutboundAddressPrefix != null ?'${vnetApim.id}/subnets/${functionsOutboundSubnetName}': null
output logicAppsInboundSubnetid string? = vNetSettings.?logicAppsInboundAddressPrefix != null ?'${vnetApim.id}/subnets/${logicAppsInboundPrivateEndpointSubnetName}'  : null
output logicAppsOutboundSubnetid string? = vNetSettings.?logicAppsOutboundAddressPrefix != null ?'${vnetApim.id}/subnets/${logicAppsOutboundSubnetName}': null
output logicAppsStorageInboundSubnetid string? = vNetSettings.?logicAppsStorageInboundAddressPrefix != null ?'${vnetApim.id}/subnets/${logicAppsStorageInboundSubnetName}'  : null
output deployScriptStorageSubnetId string? = vNetSettings.?deployScriptStorageSubnetAddressPrefix != null ?'${vnetApim.id}/subnets/${deployScriptStorageSubnetName}': null

