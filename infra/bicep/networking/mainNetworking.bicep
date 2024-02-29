import {vNetSettingsType, locationSettingType, networkingResourcesType} from '../bicepParamTypes.bicep'

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
param vNetSettings vNetSettingsType

module networkingModule './virtualNetwork.bicep' = {
    name: 'networkinvnetgresources${workloadName}${environment}${location}'
    params: {
      workloadName: workloadName
      deploymentEnvironment: environment
      location: location
      vNetSettings: vNetSettings
    }
  }


  module publicIps './publicIp.bicep' = {
    name: 'networkpublicipresources${workloadName}${environment}${location}'
    params: {
      workloadName: workloadName
      environment: environment
      location: location
    }
    dependsOn: [
      networkingModule
    ]
  }

// module firewall './firewall.bicep' = if( vNetSettings.?firewallAddressPrefix != null) {
//   name: 'networkingfirewallresources${workloadName}${environment}${location}'
//   params: {
//     workloadName: workloadName
//     deploymentEnvironment: environment
//     location: location
//     apimVNetName: networkingModule.outputs.apimVNetName
//     firewallSubnetName: networkingModule.outputs.firewallSubnetName
//     udrApimFirewallName: networkingModule.outputs.udrApimFirewallName!
//     firewallManagementSubnetName: networkingModule.outputs.firewallManagementSubnetName
//     publicIpFirewallId: publicIps.outputs.publicIpFirewallId
//     publicIpFirewallMgmtId: publicIps.outputs.publicIpFirewallMgmtId
//   }
//   dependsOn: [
//     networkingModule
//   ]
// }


var bastionName = 'bastion-${workloadName}-${environment}-${location}'	
var bastionIPConfigName = 'bastionipcfg-${workloadName}-${environment}-${location}'

resource bastion 'Microsoft.Network/bastionHosts@2020-07-01' = if(vNetSettings.?bastionAddressPrefix != null) {
  name: bastionName
  location: location 
  properties: {
    ipConfigurations: [
      {
        name: bastionIPConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIps.outputs.publicIpBastionId
          }
          subnet: {
            id: networkingModule.outputs.bastionSubnetid
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
}

