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

param deployResources bool

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
resource udrApimFirewall 'Microsoft.Network/routeTables@2023-06-01' = if (deployResources) {
  name: udrApimFirewallName
  location: location
  properties: {
    disableBgpRoutePropagation: true
  }
}


// // Network Security Groups (NSG)

// Bastion NSG must have mininal set of rules below
resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?bastionAddressPrefix != null) {
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

resource devOpsNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?devOpsAgentAddressPrefix != null) {
  name: devOpsNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}
resource jumpBoxNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?jumpBoxAddressPrefix != null) {
  name: jumpBoxNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource appGatewayNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?appGatewayAddressPrefix != null) {
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
resource functionsInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?functionsInboundAddressPrefix != null) {
  name: functionsInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource functionsOutboundNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?functionsOutboundAddressPrefix != null) {
  name: functionsOutboundNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?logicAppsInboundAddressPrefix != null) {
  name: logicAppsInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsStorageInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?logicAppsStorageInboundAddressPrefix != null) {
  name: logicAppsStorageInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource logicAppsOutboundNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?logicAppsOutboundAddressPrefix != null) {
  name: logicAppsOutboundNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource keyVaultInboundPrivateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?keyVaultInboundPrivateEndpointAddressPrefix != null) {
  name: keyVaultInboundPrivateEndpointNSGName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource apimNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (deployResources && vNetSettings.?apimAddressPrefix != null) {
  name: apimSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'Client_communication_to_API_Management'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'AzureFrontDoor.Backend'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Secure_Client_communication_to_API_Management'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureFrontDoor.Backend'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Management_endpoint_for_Azure_portal_and_Powershell'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'Dependency_on_Azure_Storage'
        properties: {
          description: 'APIM service dependency on Azure Blob and Azure Table Storage'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'Azure_Active_Directory_and_Azure_KeyVault_dependency'
        properties: {
          description: 'Connect to Azure Active Directory for Developer Portal Authentication or for Oauth2 flow during any Proxy Authentication'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_to_Azure_SQL_endpoints'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_to_Azure_KeyVault'
        properties: {
          description: 'Allow APIM service control plane access to KeyVault to refresh secrets'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureKeyVault'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_for_Log_to_event_Hub_policy_and_monitoring_agent'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '5671'
            '5672'
            '443'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 170
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_File_Share_for_GIT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 180
          direction: 'Outbound'
        }
      }
      {
        name: 'Health_and_Monitoring_Extension'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '443'
            '12000'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 190
          direction: 'Outbound'
        }
      }
      {
        name: 'Publish_Diagnostic_Logs_and_Metrics_Resource_Health_and_Application_Insights'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '1886'
            '443'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'Connect_To_SMTP_Relay_for_sending_e-mails'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '25'
            '587'
            '25028'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 210
          direction: 'Outbound'
        }
      }
      {
        name: 'Access_Redis_Service_for_Cache_policies_between_machines'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 220
          direction: 'Inbound'
        }
      }
      {
        name: 'Sync_Counters_for_Rate_Limit_policies_between_machines'
        properties: {
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 230
          direction: 'Inbound'
        }
      }
      {
        name: 'Azure_Infrastructure_Load_Balancer'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 240
          direction: 'Inbound'
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
      {
        service: 'Microsoft.ServiceBus'
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
resource vnetApim 'Microsoft.Network/virtualNetworks@2021-02-01' = if (deployResources) {
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

resource vnetApimExisting 'Microsoft.Network/virtualNetworks@2021-02-01' existing = if (!deployResources) {
  name: apimVNetName
}


var apimVNetId = deployResources ? vnetApim.id : vnetApimExisting.id

// Output section
output apimVNetName string = apimVNetName
output apimVNetId string = apimVNetId

output firewallSubnetName string = firewallSubnetName
output firewallManagementSubnetName string = firewallManagementSubnetName
output apimSubnetid string = '${apimVNetId}/subnets/${apimSubnetName}'
output appGatewaySubnetid string = '${apimVNetId}/subnets/${appGatewaySubnetName}'
output keyVaultStorageInboundSubnetid string? = vNetSettings.?keyVaultInboundPrivateEndpointAddressPrefix != null ?'${apimVNetId}/subnets/${keyVaultInboundPrivateEndpointSubnetName}': null
output firewallSubnetid string? = vNetSettings.?firewallAddressPrefix != null ?'${apimVNetId}/subnets/${firewallSubnetName}': null
output udrApimFirewallName string? = vNetSettings.?firewallAddressPrefix != null ? udrApimFirewallName: null

output bastionSubnetid string? = vNetSettings.?bastionAddressPrefix != null ? '${apimVNetId}/subnets/${bastionSubnetName}' : null
output devOpsAgentSubnetId string? = vNetSettings.?devOpsAgentAddressPrefix != null ? '${apimVNetId}/subnets/${devOpsSubnetName}'  : null
output jumpBoxSubnetid string? = vNetSettings.?jumpBoxAddressPrefix != null ? '${apimVNetId}/subnets/${jumpBoxSubnetName}'  : null
output functionsInboundSubnetid string? = vNetSettings.?functionsInboundAddressPrefix != null ?'${apimVNetId}/subnets/${functionsInboundPrivateEndpointSubnetName}'  : null
output functionsOutboundSubnetid string? = vNetSettings.?functionsOutboundAddressPrefix != null ?'${apimVNetId}/subnets/${functionsOutboundSubnetName}': null
output logicAppsInboundSubnetid string? = vNetSettings.?logicAppsInboundAddressPrefix != null ?'${apimVNetId}/subnets/${logicAppsInboundPrivateEndpointSubnetName}'  : null
output logicAppsOutboundSubnetid string? = vNetSettings.?logicAppsOutboundAddressPrefix != null ?'${apimVNetId}/subnets/${logicAppsOutboundSubnetName}': null
output logicAppsStorageInboundSubnetid string? = vNetSettings.?logicAppsStorageInboundAddressPrefix != null ?'${apimVNetId}/subnets/${logicAppsStorageInboundSubnetName}'  : null
output deployScriptStorageSubnetId string? = vNetSettings.?deployScriptStorageSubnetAddressPrefix != null ?'${apimVNetId}/subnets/${deployScriptStorageSubnetName}': null

