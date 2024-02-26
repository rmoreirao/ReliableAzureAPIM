// Input parameters for the deployment

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
type apimRegionalSettingsType = {
  skuCapacity: int
}

@export()
type apimGlobalSettingsType = {
  apimSkuName: 'Developer' | 'Premium'
  
  @description('The email address of the publisher of the APIM resource.')
  @minLength(1)
  apimPublisherEmail : string
  
  @description('Company name of the publisher of the APIM resource.')
  @minLength(1)
  apimPublisherName : string

  @description('Custom domain for APIM - is used to API Management from the internet. This should also match the Domain name of your Certificate. Example - contoso.com.')
  apimCustomDomainName : string
  
  @description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to deployment/bicep/gateway/certs/appgw.pfx')
  @secure()
  apimAppGatewayCertificatePassword : string
  
  @description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
  apimAppGatewayCertType : 'selfsigned' | 'custom'
}

@export()
type locationSettingType = {
  location: string
  vNetSettings: vNetSettingsType
  apimRegionalSettings: apimRegionalSettingsType
}

// Types related to the output of the deployment
// Avoid using these types as input parameters to reduce the dependencies between different components

@export()
type networkingResourcesType = {
  vnetId: string
  apimVNetName: string
  apimSubnetid: string
  apimPublicIpId: string
  appGatewaySubnetid: string
  appGatewayPublicIpId: string
  logicAppsStorageInboundSubnetid:string?
  devOpsAgentSubnetId: string?
  jumpBoxSubnetid: string?
  deployScriptStorageSubnetId: string?
  keyVaultPrivateEndpointSubnetid:string?
}

@export()
type sharedResourcesType = {
  appInsightsConnectionString : string
  appInsightsName : string
  appInsightsId : string
  appInsightsInstrumentationKey : string
  logAnalyticsWorkspaceId : string
  keyVaultName : string?
}
