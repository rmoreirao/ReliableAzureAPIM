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
  networkingRGSettings : {
    @description('Indicates whether the deployment should be done or not. If not, current resources will be used to retrieve the resources settings. The objective of this parameter is to avoid redeploys and speed up testing.')
    deployResources: bool
    publicIpAvailabilityZones: avalabilityZoneType[]?    

    firewallSettings : {
      firewallSkuName: 'Basic' | 'Standard'
      availabilityZones: avalabilityZoneType[]?
    }?
  }

  apimRGSettings : {
    apimSettings : {
      deployResources: bool
      apimSkuName: 'Developer' | 'Premium'
      @description('The email address of the publisher of the APIM resource.')
      @minLength(1)
      apimPublisherEmail : string
      @description('Company name of the publisher of the APIM resource.')
      @minLength(1)
      apimPublisherName : string
      @description('Custom domain for APIM - is used to API Management from the internet. This should also match the Domain name of your Certificate. Example - contoso.com.')
      apimCustomDomainName : string
      
      @description('Client Id for of the Entra ID application for Authorization. Set this to enable Entra ID integration for Developer Portal.')
      entraIdClientId:string?
      @description('Client Secret for of the Entra ID application for Authorization.')
      @secure()
      entraIdClientSecret: string?
    }
  
    appGatewaySettings: {
      deployResources: bool
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
  }
 
  sharedRGSettings : {
    deployResources: bool

    devOpsAgentSettings : devOpsAgentSettingsType?

    jumpBoxSettings : jumpBoxSettingsType?
  }

  backendRGSettings : {
    deployResources: bool
    storageSku : 'Standard_LRS' | 'Standard_ZRS'
  }
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

@export()
type apimRegionalResourcesType = {
  apimPrivateIpAddress : string
  apimGatewayURL : string
  apimDevPortalURL : string?
  apimManagementBackendEndURL : string?
}
