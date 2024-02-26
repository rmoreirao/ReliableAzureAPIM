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
// param locationSettings locationSettingType[]




// module networkingModule './virtualNetwork.bicep' = [for (locationSetting,i) in locationSettings: {
//   name: 'networkinvnetgresources${i}'
//   params: {
//     workloadName: workloadName
//     deploymentEnvironment: environment
//     location: locationSetting.location
//     vNetSettings: locationSetting.vNetSettings
//   }
// }]

module networkingModule './virtualNetwork.bicep' = {
    name: 'networkinvnetgresources${workloadName}${environment}${location}'
    params: {
      workloadName: workloadName
      deploymentEnvironment: environment
      location: location
      vNetSettings: vNetSettings
    }
  }

module firewall './firewall.bicep' ={
  name: 'networkingfirewallresources${workloadName}${environment}${location}'
  params: {
    workloadName: workloadName
    deploymentEnvironment: environment
    location: location
    apimVNetName: networkingModule.outputs.apimVNetName
    firewallSubnetName: networkingModule.outputs.firewallSubnetName
    udrApimFirewallName: networkingModule.outputs.udrApimFirewallName
    firewallManagementSubnetName: networkingModule.outputs.firewallManagementSubnetName
  }
  dependsOn: [
    networkingModule
  ]
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


// output outputArray networkingOutputType[] = [ for (locationSetting,i) in locationSettings: {
output resources networkingResourcesType = {
  apimVNetName : networkingModule.outputs.apimVNetName
  logicAppsStorageInboundSubnetid : networkingModule.outputs.logicAppsStorageInboundSubnetid
  CICDAgentSubnetId : networkingModule.outputs.CICDAgentSubnetId
  jumpBoxSubnetid : networkingModule.outputs.jumpBoxSubnetid
  apimSubnetid : networkingModule.outputs.apimSubnetid
  apimPublicIpId : publicIps.outputs.apimPublicIpId
  appGatewaySubnetid : networkingModule.outputs.appGatewaySubnetid
  deployScriptStorageSubnetId : networkingModule.outputs.deployScriptStorageSubnetId
  appGatewayPublicIpId : publicIps.outputs.appGatewayPublicIpId
  keyVaultPrivateEndpointSubnetid: networkingModule.outputs.keyVaultStorageInboundSubnetid
  vnetId: networkingModule.outputs.apimVNetId
}

// }]
