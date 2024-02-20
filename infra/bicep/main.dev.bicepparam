using './main.bicep'

param workloadName = 'rmor4'
param environment = 'dev'
param devOpsVmUsername = 'vmadmin'
param devOpsCICDAgentType = 'none'
param devOpsAccountName = 'https://dev.azure.com/rmoreiraoms'
param apimCustomDomainName = 'rmoreirao-apim-custom-domain.com'
param apimAppGatewayCertificatePassword = ''
param apimAppGatewayCertType = 'selfsigned'
param apimPublisherEmail = 'rmoreirao@microsoft.com'
param apimPublisherName = 'Carnaval Integration Services'
param location = 'uksouth'

