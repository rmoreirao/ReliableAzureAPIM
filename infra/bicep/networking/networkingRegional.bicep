import {vNetRegionalSettingsType, regionalSettingType, networkingResourcesType, avalabilityZoneType} from '../bicepParamTypes.bicep'

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
param location string 
param vNetSettings vNetRegionalSettingsType
param firewallSku 'Basic' | 'Standard'?
param firewallAvailabilityZones avalabilityZoneType[]?
param publicIpAvailabilityZones avalabilityZoneType[]?
param deployResources bool

module networkingModule './virtualNetwork.bicep' = {
    name: 'virtualNetwork${workloadName}${environment}${location}'
    params: {
      workloadName: workloadName
      deploymentEnvironment: environment
      location: location
      vNetSettings: vNetSettings
      deployResources: deployResources
    }
  }


  module publicIps './publicIp.bicep' = {
    name: 'networkpublicipresources${workloadName}${environment}${location}'
    params: {
      workloadName: workloadName
      environment: environment
      location: location
      vNetSettings: vNetSettings
      availabilityZones: publicIpAvailabilityZones
      deployResources:deployResources
    }
    dependsOn: [
      networkingModule
    ]
  }

module firewall './firewall.bicep' = if( vNetSettings.?firewallAddressPrefix != null && firewallSku != null) {
  name: 'networkingfirewallresources${workloadName}${environment}${location}'
  params: {
    workloadName: workloadName
    deploymentEnvironment: environment
    location: location
    apimVNetName: networkingModule.outputs.apimVNetName
    firewallSubnetName: networkingModule.outputs.firewallSubnetName
    udrApimFirewallName: networkingModule.outputs.udrApimFirewallName!
    firewallManagementSubnetName: networkingModule.outputs.firewallManagementSubnetName
    publicIpFirewallId: publicIps.outputs.publicIpFirewallId!
    publicIpFirewallMgmtId: publicIps.outputs.publicIpFirewallMgmtId
    sku: firewallSku!
    availabilityZones: firewallAvailabilityZones
    deployResources: deployResources
  }
  dependsOn: [
    networkingModule
  ]
}


var bastionName = 'bastion-${workloadName}-${environment}-${location}'	
var bastionIPConfigName = 'bastionipcfg-${workloadName}-${environment}-${location}'

resource bastion 'Microsoft.Network/bastionHosts@2020-07-01' = if(deployResources && vNetSettings.?bastionAddressPrefix != null) {
  name: bastionName
  location: location 
  properties: {
    ipConfigurations: [
      {
        name: bastionIPConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIps.outputs.?publicIpBastionId
          }
          subnet: {
            id: networkingModule.outputs.?bastionSubnetid
          }
        }
      }
    ]
  }
}

output resources networkingResourcesType = {
  vnetId: networkingModule.outputs.apimVNetId
  apimVNetName : networkingModule.outputs.apimVNetName
  apimSubnetid : networkingModule.outputs.apimSubnetid
  apimPublicIpId : publicIps.outputs.apimPublicIpId
  appGatewayPublicIpId : publicIps.outputs.appGatewayPublicIpId
  appGatewaySubnetid : networkingModule.outputs.appGatewaySubnetid
  logicAppsStorageInboundSubnetid : networkingModule.outputs.?logicAppsStorageInboundSubnetid
  devOpsAgentSubnetId : networkingModule.outputs.?devOpsAgentSubnetId
  jumpBoxSubnetid : networkingModule.outputs.?jumpBoxSubnetid
  deployScriptStorageSubnetId : networkingModule.outputs.?deployScriptStorageSubnetId
  
  keyVaultPrivateEndpointSubnetid: networkingModule.outputs.?keyVaultStorageInboundSubnetid
  
  functionsInboundSubnetid: networkingModule.outputs.?functionsInboundSubnetid
  functionsOutboundSubnetid: networkingModule.outputs.?functionsOutboundSubnetid
  logicAppsInboundSubnetid: networkingModule.outputs.?logicAppsInboundSubnetid
  logicAppsOutboundSubnetid: networkingModule.outputs.?logicAppsOutboundSubnetid
}

