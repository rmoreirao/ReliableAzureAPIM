// import {vNetSettingsType, locationSettingType} from '../exportParamTypes.bicep'

// @description('A short name for the workload being deployed alphanumberic only')
// @maxLength(8)
// param workloadName string

// @description('The environment for which the deployment is being executed')
// @allowed([
//   'dev'
//   'uat'
//   'prod'
//   'dr'
// ])
// param environment string
// param location string
// param vNetSettings vNetSettingsType

// module networkingModule './virtualNetwork.bicep' = {
//   name: 'networkinvnetgresources'
//   params: {
//     workloadName: workloadName
//     deploymentEnvironment: environment
//     location: location
//     vNetSettings: vNetSettings
//   }
// }



// module firewall './firewall.bicep' = {
//   name: 'networkingfirewallresources'
//   params: {
//     workloadName: workloadName
//     deploymentEnvironment: environment
//     location: location
//     apimVNetName: networkingModule.outputs.apimVNetName
//     firewallSubnetName: networkingModule.outputs.firewallSubnetName
//     udrApimFirewallName: networkingModule.outputs.udrApimFirewallName
//     firewallManagementSubnetName: networkingModule.outputs.firewallManagementSubnetName
//   }
//   dependsOn: [
//     networkingModule
//   ]
// }

// module publicIps './publicIp.bicep' = {
//   name: 'networkpublicipresources'
//   params: {
//     workloadName: workloadName
//     environment: environment
//     location: location
//     vnetApimId: networkingModule.outputs.apimVNetId
//   }
//   dependsOn: [
//     networkingModule
//   ]
// }

// output apimVNetName string = networkingModule.outputs.apimVNetName
// output logicAppsStorageInboundSubnetid string = networkingModule.outputs.logicAppsStorageInboundSubnetid
// output CICDAgentSubnetId string = networkingModule.outputs.CICDAgentSubnetId
// output jumpBoxSubnetid string = networkingModule.outputs.jumpBoxSubnetid
// output apimSubnetid string = networkingModule.outputs.apimSubnetid
// output publicIpId string = publicIps.outputs.publicIpId
// output appGatewaySubnetid string = networkingModule.outputs.appGatewaySubnetid
// output deployScriptStorageSubnetId string = networkingModule.outputs.deployScriptStorageSubnetId
// output appGatewayPublicIpId string = publicIps.outputs.appGatewayPublicIpId
