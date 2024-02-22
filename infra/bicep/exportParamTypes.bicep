@export()
type vNetSettingsType = {
  apimVNetNameAddressPrefix :  string
  apimAddressPrefix : string
  firewallAddressPrefix : string
  appGatewayAddressPrefix : string
  bastionAddressPrefix : string?
  devOpsNameAddressPrefix : string?
  jumpBoxAddressPrefix : string?
  functionsInboundAddressPrefix : string?
  functionsOutboundAddressPrefix : string?
  logicAppsOutboundAddressPrefix : string?
  logicAppsInboundAddressPrefix : string?
  logicAppsStorageInboundAddressPrefix : string?
}

@export()
type additionalRegionsType = {
  location: string
  vNetSettingsAdditionalRegion: vNetSettingsType
}
