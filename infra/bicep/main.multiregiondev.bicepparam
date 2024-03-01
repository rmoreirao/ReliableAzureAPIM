using './main.bicep'

param workloadName = 'mltd2'
param environment = 'dev'

param devOpsResourcesSettings = {
   devOpsAccountName: 'https://dev.azure.com/rmoreiraoms'
   devOpsCICDAgentType: 'none'
   devOpsPersonalAccessToken: '{{DEVOPS_PAT}}'
   devOpsVmPassword: '{{DEVOPS_VMPASSWORD}}'
   devOpsVmUsername: 'vmadmin'
}

param jumpBoxResourcesSettings = {
  jumpBoxVmPassword: '{{JUMPBOX_VMPASSWORD}}'
  jumpBoxVmUsername: 'vmadmin'
}

param apimGlobalSettings = {
  apimPublisherEmail : 'rmoreirao@microsoft.com'
  apimPublisherName : 'Contoso Sandbox APIM'
  apimAppGatewayCertificatePassword : ''
  apimAppGatewayCertType : 'selfsigned'
  apimCustomDomainName : 'contoso-sandbox-apim.com'
  apimSkuName: 'Premium'
}

param locationSettings = [
  {
    location: 'uksouth'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.7.0.0/16'
        // bastionAddressPrefix : '10.7.1.0/24'
        // devOpsNameAddressPrefix : '10.7.2.0/24'
        // jumpBoxAddressPrefix : '10.7.3.0/24'
        appGatewayAddressPrefix : '10.7.4.0/24'
        // functionsInboundAddressPrefix : '10.7.5.0/24'
        // functionsOutboundAddressPrefix : '10.7.6.0/24'
        apimAddressPrefix : '10.7.7.0/24'
        firewallAddressPrefix : '10.7.8.0/24'
        firewallManagementAddressPrefix : '10.7.9.0/24'
        // logicAppsOutboundAddressPrefix : '10.7.10.0/24'
        // logicAppsInboundAddressPrefix : '10.7.11.0/24'
        // logicAppsStorageInboundAddressPrefix : '10.7.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.7.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.7.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
  {
    location: 'germanywestcentral'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.8.0.0/16'
        appGatewayAddressPrefix : '10.8.4.0/24'
        apimAddressPrefix : '10.8.7.0/24'
        firewallAddressPrefix : '10.8.8.0/24'
        firewallManagementAddressPrefix : '10.8.9.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.8.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.8.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
]
