using './main.bicep'

param workloadName = 'hkdi2'
param environment = 'dev'

param globalSettings = {
  networkingSettings:{
    publicIpAvailabilityZones:['1']
  }

  apimSettings:{
    apimPublisherEmail : 'rmoreirao@microsoft.com'
    apimPublisherName : 'Heineken DI'
    apimCustomDomainName : 'sandbox.heineken-apim.com'
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
    location: 'westeurope'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.5.0.0/16'
        bastionAddressPrefix : '10.5.1.0/24'
        // devOpsAgentAddressPrefix : '10.5.2.0/24'
        jumpBoxAddressPrefix : '10.5.3.0/24'
        appGatewayAddressPrefix : '10.5.4.0/24'
        functionsInboundAddressPrefix : '10.5.5.0/24'
        functionsOutboundAddressPrefix : '10.5.6.0/24'
        apimAddressPrefix : '10.5.7.0/24'
        firewallAddressPrefix : '10.5.8.0/24'
        firewallManagementAddressPrefix : '10.5.9.0/24'
        logicAppsOutboundAddressPrefix : '10.5.10.0/24'
        logicAppsInboundAddressPrefix : '10.5.11.0/24'
        logicAppsStorageInboundAddressPrefix : '10.5.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.5.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.5.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
]
