using './main.bicep'

param workloadName = 'rmor1'
param environment = 'dev'
param devOpsVmUsername = 'vmadmin'
param devOpsCICDAgentType = 'none'
param devOpsAccountName = 'https://dev.azure.com/rmoreiraoms'

param devOpsVmPassword='{{DEVOPS_VMPASSWORD}} '
param devOpsPersonalAccessToken='{{DEVOPS_PAT}}'

param apimGlobalSettings = {
  apimPublisherEmail : 'rmoreirao@microsoft.com'
  apimPublisherName : 'Carnaval Integration Services'
  apimAppGatewayCertificatePassword : ''
  apimAppGatewayCertType : 'selfsigned'
  apimCustomDomainName : 'rmoreirao-apim-custom-domain.com'
  apimSkuName: 'Developer'
}  

param location = 'uksouth'

param locationSettings = [
  {
    location: 'uksouth'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.2.0.0/16'
        // bastionAddressPrefix : '10.2.1.0/24'
        // devOpsNameAddressPrefix : '10.2.2.0/24'
        // jumpBoxAddressPrefix : '10.2.3.0/24'
        appGatewayAddressPrefix : '10.2.4.0/24'
        functionsInboundAddressPrefix : '10.2.5.0/24'
        functionsOutboundAddressPrefix : '10.2.6.0/24'
        apimAddressPrefix : '10.2.7.0/24'
        firewallAddressPrefix : '10.2.8.0/24'
        firewallManagementAddressPrefix : '10.2.9.0/24'
        logicAppsOutboundAddressPrefix : '10.2.10.0/24'
        logicAppsInboundAddressPrefix : '10.2.11.0/24'
        logicAppsStorageInboundAddressPrefix : '10.2.12.0/24'
        deployScriptStorageSubnetAddressPrefix: '10.2.14.0/24'
        keyVaultInboundPrivateEndpointAddressPrefix : '10.2.15.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
  {
    location: 'westeurope'
    vNetSettings: {
        apimVNetNameAddressPrefix :'10.3.0.0/16'
        appGatewayAddressPrefix : '10.3.4.0/24'
        apimAddressPrefix : '10.3.7.0/24'
        firewallAddressPrefix : '10.3.8.0/24'
        firewallManagementAddressPrefix : '10.3.9.0/24'
    }
    apimRegionalSettings:{
      skuCapacity: 1
    }
  }
]
  

// param additionalRegions = []
