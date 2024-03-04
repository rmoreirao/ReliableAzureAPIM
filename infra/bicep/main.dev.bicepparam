using './main.bicep'

param workloadName = 'dihk8'
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
        apimVNetNameAddressPrefix :'10.8.0.0/16'
        // bastionAddressPrefix : '10.8.1.0/24'
        // devOpsAgentAddressPrefix : '10.8.2.0/24'
        // jumpBoxAddressPrefix : '10.8.3.0/24'
        appGatewayAddressPrefix : '10.8.4.0/24'
        functionsInboundAddressPrefix : '10.8.5.0/24'
        functionsOutboundAddressPrefix : '10.8.6.0/24'
        apimAddressPrefix : '10.8.7.0/24'
        firewallAddressPrefix : '10.8.8.0/24'
        firewallManagementAddressPrefix : '10.8.9.0/24'
        logicAppsOutboundAddressPrefix : '10.8.10.0/24'
        logicAppsInboundAddressPrefix : '10.8.11.0/24'
        logicAppsStorageInboundAddressPrefix : '10.8.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.8.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.8.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
]
