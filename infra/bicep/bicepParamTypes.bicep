// Input parameters for the deployment

@export()
type vNetRegionalSettingsType = {
  apimVNetNameAddressPrefix :  string
  apimAddressPrefix : string
  appGatewayAddressPrefix : string
  
  firewallAddressPrefix : string?
  firewallManagementAddressPrefix : string?

  bastionAddressPrefix : string?
  devOpsAgentAddressPrefix : string?
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
type avalabilityZoneType = '1' | '2' | '3'

@export()
type apimRegionalSettingsType = {
  @description('The instance size of this API Management service. This should be a multiple of the number of availability zones getting deployed.')
  skuCapacity: int

  @description('Numbers for availability zones, for example, 1,2,3.')
  availabilityZones: avalabilityZoneType[]?
}

@export()
type regionalSettingType = {
  location: string
  vNetSettings: vNetRegionalSettingsType
  apimRegionalSettings: apimRegionalSettingsType
}

@export()
type devOpsAgentSettingsType = {
  @description('The user name to be used as the Administrator for all VMs created by this deployment')
    devOpsVmUsername :string
    @description('The password for the Administrator user for all VMs created by this deployment')
    @secure()
    devOpsVmPassword:string
    @description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
    devOpsCICDAgentType : 'github' | 'azuredevops' | 'none'
    @description('The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none')
    devOpsAccountName :string
    @description('The Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent')
    @secure()
    devOpsPersonalAccessToken:string
}

@export()
type jumpBoxSettingsType = {
  @description('The user name to be used as the Administrator for all VMs created by this deployment')
  jumpBoxVmUsername :string
  @description('The password for the Administrator user for all VMs created by this deployment')
  @secure()
  jumpBoxVmPassword :string

}

@export()
type globalSettingsType = {
  apimSettings : {
    apimSkuName: 'Developer' | 'Premium'
    @description('The email address of the publisher of the APIM resource.')
    @minLength(1)
    apimPublisherEmail : string
    @description('Company name of the publisher of the APIM resource.')
    @minLength(1)
    apimPublisherName : string
    @description('Custom domain for APIM - is used to API Management from the internet. This should also match the Domain name of your Certificate. Example - contoso.com.')
    apimCustomDomainName : string
  }
  
  appGatewaySettings: {
    @description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to deployment/bicep/gateway/certs/appgw.pfx')
    @secure()
    apimAppGatewayCertificatePassword : string
  
    @description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
    apimAppGatewayCertType : 'selfsigned' | 'custom'
    appGatewaySkuName: 'Standard_v2' | 'WAF_v2'
    availabilityZones: avalabilityZoneType[]?
    minCapacity: int
    maxCapacity: int
  }

  firewallSettings : {
    firewallSkuName: 'Basic' | 'Standard'
    availabilityZones: avalabilityZoneType[]?
  }

  devOpsAgentSettings : devOpsAgentSettingsType?

  jumpBoxSettings : jumpBoxSettingsType?
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
  functionsInboundSubnetid: string?
  functionsOutboundSubnetid: string?
  logicAppsInboundSubnetid: string?
  logicAppsOutboundSubnetid: string?
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
