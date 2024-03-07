using './main.bicep'

param workloadName = 'rmo9'
param environment = 'dev'

param globalSettings = {
  networkingSettings:{
    publicIpAvailabilityZones:['1']
  }

  apimSettings:{
    apimPublisherEmail : 'rmoreirao@microsoft.com'
    apimPublisherName : 'Contoso Sandbox APIM'
    apimCustomDomainName : 'contoso-sandbox-apim.com'
    apimSkuName: 'Developer'
    
  }
  appGatewaySettings:{
    apimAppGatewayCertificatePassword : ''
    apimAppGatewayCertType : 'selfsigned'
    appGatewaySkuName: 'WAF_v2'
    minCapacity: 1
    maxCapacity: 2
    availabilityZones:['1']
  }

  // devOpsAgentSettings: {
  //   devOpsAccountName: 'https://dev.azure.com/rmoreiraoms'
  //   devOpsCICDAgentType: 'none'
  //   devOpsPersonalAccessToken: '{{DEVOPS_PAT}}'
  //   devOpsVmPassword: '{{DEVOPS_VMPASSWORD}}'
  //   devOpsVmUsername: 'vmadmin'
  // }

  jumpBoxSettings:{
    jumpBoxVmPassword: '{{JUMPBOX_VMPASSWORD}}'
    jumpBoxVmUsername: 'vmadmin'
  }

  firewallSettings:{
    firewallSkuName:'Basic'
    availabilityZones:['1']
  }
}  

param regionalSettings = [
  {
    location: 'uksouth'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.3.0.0/16'
        bastionAddressPrefix : '10.3.1.0/24'
        // devOpsAgentAddressPrefix : '10.3.2.0/24'
        jumpBoxAddressPrefix : '10.3.3.0/24'
        appGatewayAddressPrefix : '10.3.4.0/24'
        functionsInboundAddressPrefix : '10.3.5.0/24'
        functionsOutboundAddressPrefix : '10.3.6.0/24'
        apimAddressPrefix : '10.3.7.0/24'
        firewallAddressPrefix : '10.3.8.0/24'
        firewallManagementAddressPrefix : '10.3.9.0/24'
        logicAppsOutboundAddressPrefix : '10.3.10.0/24'
        logicAppsInboundAddressPrefix : '10.3.11.0/24'
        logicAppsStorageInboundAddressPrefix : '10.3.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.3.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.3.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
]
