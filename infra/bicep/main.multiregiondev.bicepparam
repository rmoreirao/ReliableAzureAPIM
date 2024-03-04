using './main.bicep'

//max length of 128 characters
param workloadName = 'dimt1'
param environment = 'dev'
param globalSettings = {
  apimSettings:{
    apimPublisherEmail : 'rmoreirao@microsoft.com'
    apimPublisherName : 'Contoso Sandbox APIM'
    apimCustomDomainName : 'contoso-sandbox-apim.com'
    apimSkuName: 'Developer'
    
  }
  appGatewaySettings:{
    apimAppGatewayCertificatePassword : ''
    apimAppGatewayCertType : 'selfsigned'
    appGatewaySkuName: 'Standard_v2'
    minCapacity: 1
    maxCapacity: 2
    availabilityZones:['1']
  }
  
  devOpsAgentSettings: {
    devOpsAccountName: 'https://dev.azure.com/rmoreiraoms'
    devOpsCICDAgentType: 'none'
    devOpsPersonalAccessToken: '{{DEVOPS_PAT}}'
    devOpsVmPassword: '{{DEVOPS_VMPASSWORD}}'
    devOpsVmUsername: 'vmadmin'
  }

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
        apimVNetNameAddressPrefix :'10.10.0.0/16'
        // bastionAddressPrefix : '10.10.1.0/24'
        // devOpsAgentAddressPrefix : '10.10.2.0/24'
        // jumpBoxAddressPrefix : '10.10.3.0/24'
        appGatewayAddressPrefix : '10.10.4.0/24'
        // functionsInboundAddressPrefix : '10.10.5.0/24'
        // functionsOutboundAddressPrefix : '10.10.6.0/24'
        apimAddressPrefix : '10.10.7.0/24'
        firewallAddressPrefix : '10.10.8.0/24'
        firewallManagementAddressPrefix : '10.10.9.0/24'
        // logicAppsOutboundAddressPrefix : '10.10.10.0/24'
        // logicAppsInboundAddressPrefix : '10.10.11.0/24'
        // logicAppsStorageInboundAddressPrefix : '10.10.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.10.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.10.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
  {
    location: 'germanywestcentral'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.11.0.0/16'
        appGatewayAddressPrefix : '10.11.4.0/24'
        apimAddressPrefix : '10.11.7.0/24'
        firewallAddressPrefix : '10.11.8.0/24'
        firewallManagementAddressPrefix : '10.11.9.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.11.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.11.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
]
