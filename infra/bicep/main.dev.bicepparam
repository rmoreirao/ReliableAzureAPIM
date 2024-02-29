using './main.bicep'

param workloadName = 'dihk5'
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
  apimSkuName: 'Developer'
}  

param locationSettings = [
  {
    location: 'westeurope'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.3.0.0/16'
        // bastionAddressPrefix : '10.3.1.0/24'
        // devOpsNameAddressPrefix : '10.3.2.0/24'
        // jumpBoxAddressPrefix : '10.3.3.0/24'
        appGatewayAddressPrefix : '10.3.4.0/24'
        // functionsInboundAddressPrefix : '10.3.5.0/24'
        // functionsOutboundAddressPrefix : '10.3.6.0/24'
        apimAddressPrefix : '10.3.7.0/24'
        // firewallAddressPrefix : '10.3.8.0/24'
        // firewallManagementAddressPrefix : '10.3.9.0/24'
        // logicAppsOutboundAddressPrefix : '10.3.10.0/24'
        // logicAppsInboundAddressPrefix : '10.3.11.0/24'
        // logicAppsStorageInboundAddressPrefix : '10.3.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.3.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.3.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
  // {
  //   location: 'westeurope'
  //   vNetSettings: {
  //       apimVNetNameAddressPrefix :'10.3.0.0/16'
  //       appGatewayAddressPrefix : '10.3.4.0/24'
  //       apimAddressPrefix : '10.3.7.0/24'
  //       firewallAddressPrefix : '10.3.8.0/24'
  //       firewallManagementAddressPrefix : '10.3.9.0/24'
  //       deployScriptStorageSubnetAddressPrefix: '10.3.14.0/24'
  //       keyVaultInboundPrivateEndpointAddressPrefix : '10.3.15.0/24'
  //   }
  //   apimRegionalSettings:{
  //     skuCapacity: 1
  //   }
  // }
]
