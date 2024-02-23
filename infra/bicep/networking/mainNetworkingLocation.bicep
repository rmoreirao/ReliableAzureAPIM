import {vNetSettingsType, locationSettingType, networkingOutputType} from '../exportParamTypes.bicep'

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
// param vNetSettings vNetSettingsType
param locationSettings locationSettingType[]




module networkingModule './virtualNetwork.bicep' = [for (locationSetting,i) in locationSettings: {
  name: 'networkinvnetgresources${i}'
  params: {
    workloadName: workloadName
    deploymentEnvironment: environment
    location: locationSetting.location
    vNetSettings: locationSetting.vNetSettings
  }
}]



module firewall './firewall.bicep' = [for (locationSetting,i) in locationSettings: {
  name: 'networkingfirewallresources${i}'
  params: {
    workloadName: workloadName
    deploymentEnvironment: environment
    location: locationSetting.location
    apimVNetName: networkingModule[i].outputs.apimVNetName
    firewallSubnetName: networkingModule[i].outputs.firewallSubnetName
    udrApimFirewallName: networkingModule[i].outputs.udrApimFirewallName
    firewallManagementSubnetName: networkingModule[i].outputs.firewallManagementSubnetName
  }
  dependsOn: [
    networkingModule
  ]
}]

module publicIps './publicIp.bicep' = [for (locationSetting,i) in locationSettings: {
  name: 'networkpublicipresources${i}'
  params: {
    workloadName: workloadName
    environment: environment
    location: locationSetting.location
  }
  dependsOn: [
    networkingModule
  ]
}]

var bastionName = 'bastion-${workloadName}-${environment}-${locationSettings[0].location}'	
var bastionIPConfigName = 'bastionipcfg-${workloadName}-${environment}-${locationSettings[0].location}'

resource bastion 'Microsoft.Network/bastionHosts@2020-07-01' = if(locationSettings[0].vNetSettings.?bastionAddressPrefix != null) {
  name: bastionName
  location: locationSettings[0].location 
  properties: {
    ipConfigurations: [
      {
        name: bastionIPConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIps[0].outputs.publicIpBastionId             
          }
          subnet: {
            id: networkingModule[0].outputs.bastionSubnetid
          }
        }
      }
    ]
  }
}


output outputArray networkingOutputType[] = [ for (locationSetting,i) in locationSettings: {
  apimVNetName: networkingModule[i].outputs.apimVNetName
  logicAppsStorageInboundSubnetid: networkingModule[i].outputs.logicAppsStorageInboundSubnetid
  CICDAgentSubnetId: networkingModule[i].outputs.CICDAgentSubnetId
  jumpBoxSubnetid: networkingModule[i].outputs.jumpBoxSubnetid
  apimSubnetid: networkingModule[i].outputs.apimSubnetid
  apimPublicIpId: publicIps[i].outputs.apimPublicIpId
  appGatewaySubnetid: networkingModule[i].outputs.appGatewaySubnetid
  deployScriptStorageSubnetId: networkingModule[i].outputs.deployScriptStorageSubnetId
  appGatewayPublicIpId: publicIps[i].outputs.appGatewayPublicIpId
}]
