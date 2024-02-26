
@export()
type vNetSettingsType = {
  apimVNetNameAddressPrefix :  string
  apimAddressPrefix : string
  firewallAddressPrefix : string
  firewallManagementAddressPrefix : string
  appGatewayAddressPrefix : string
  bastionAddressPrefix : string?
  devOpsNameAddressPrefix : string?
  jumpBoxAddressPrefix : string?
  functionsInboundAddressPrefix : string?
  functionsOutboundAddressPrefix : string?
  logicAppsOutboundAddressPrefix : string?
  logicAppsInboundAddressPrefix : string?
  logicAppsStorageInboundAddressPrefix : string?
  deployScriptStorageSubnetAddressPrefix : string?
  keyVaultInboundPrivateEndpointAddressPrefix : string?
}

@export()
type locationSettingType = {
  location: string
  vNetSettings: vNetSettingsType
}

@export()
type networkingResourcesType = {
  apimVNetName: string
  logicAppsStorageInboundSubnetid:string
  CICDAgentSubnetId: string
  jumpBoxSubnetid: string
  apimSubnetid: string
  apimPublicIpId: string
  appGatewaySubnetid: string
  deployScriptStorageSubnetId: string
  appGatewayPublicIpId: string
  keyVaultPrivateEndpointSubnetid:string
  vnetId: string
}


@export()
type sharedResourcesType = {
  appInsightsConnectionString : string
  appInsightsName : string
  appInsightsId : string
  appInsightsInstrumentationKey : string
  keyVaultName : string
  logAnalyticsWorkspaceId : string
}
