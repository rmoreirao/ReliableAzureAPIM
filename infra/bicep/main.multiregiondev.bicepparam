using './main.bicep'

//max length of 5 characters
param workloadName = 'apml2'
param environment = 'dev'
param globalSettings = {
  networkingRGSettings:{
    deployResources:false
    publicIpAvailabilityZones:['1']

    firewallSettings:{
      firewallSkuName:'Basic'
      availabilityZones:['1']
    }
  }

  backendRGSettings: {
    deployResources: false
    storageSku: 'Standard_LRS'
  }

  apimRGSettings:{
    
    apimSettings:{
      deployResources: false
      apimPublisherEmail : 'rmoreirao@microsoft.com'
      apimPublisherName : 'Contoso Sandbox APIM'
      apimCustomDomainName : 'contoso-sandbox-apim.com'
      apimSkuName: 'Premium'
      
    }
    appGatewaySettings:{
      deployResources: true
      apimAppGatewayCertificatePassword : ''
      apimAppGatewayCertType : 'selfsigned'
      appGatewaySkuName: 'WAF_v2'
      minCapacity: 1
      maxCapacity: 2
      availabilityZones:['1']
    }
  }

  sharedRGSettings:{
    deployResources: false
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
  }
}  

param regionalSettings = [
  {
    location: 'uksouth'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.12.0.0/16'
        // bastionAddressPrefix : '10.12.1.0/24'
        // devOpsAgentAddressPrefix : '10.12.2.0/24'
        // jumpBoxAddressPrefix : '10.12.3.0/24'
        appGatewayAddressPrefix : '10.12.4.0/24'
        // functionsInboundAddressPrefix : '10.12.5.0/24'
        // functionsOutboundAddressPrefix : '10.12.6.0/24'
        apimAddressPrefix : '10.12.7.0/24'
        firewallAddressPrefix : '10.12.8.0/24'
        firewallManagementAddressPrefix : '10.12.9.0/24'
        // logicAppsOutboundAddressPrefix : '10.12.10.0/24'
        // logicAppsInboundAddressPrefix : '10.12.11.0/24'
        // logicAppsStorageInboundAddressPrefix : '10.12.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.12.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.12.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
  {
    location: 'germanywestcentral'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.13.0.0/16'
        appGatewayAddressPrefix : '10.13.4.0/24'
        apimAddressPrefix : '10.13.7.0/24'
        firewallAddressPrefix : '10.13.8.0/24'
        firewallManagementAddressPrefix : '10.13.9.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.13.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.13.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
]
