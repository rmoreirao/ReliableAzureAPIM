import {networkingResourcesType, sharedResourcesType, apimRegionalSettingsType , regionalSettingType} from '../bicepParamTypes.bicep'

targetScope='resourceGroup'
param resourceSuffix string

@description('The subnet resource id to use for APIM.')
@minLength(1)
param apimSubnetId string

@description('The public IP resource id to use for APIM.  In internal VNet mode, this public IP address is used only for management operations.')
param apimPublicIpId string

@description('The email address of the publisher of the APIM resource.')
@minLength(1)
param publisherEmail string

@description('Company name of the publisher of the APIM resource.')
@minLength(1)
param publisherName string

@description('The pricing tier of the APIM resource.')
param skuName string

param primaryRegionSettings regionalSettingType

param additionalRegionSettings regionalSettingType[]
param additionalRegionsNetworkingResources networkingResourcesType[]

param appInsightsName string
param appInsightsId string
param appInsightsInstrumentationKey string

param keyVaultName string
param keyVaultRG string

param deployCustomDnsNames bool = false
param certificateSecretUriWithoutVersion string?
param apimCustomDomainName string?

param entraIdClientId string?
@secure()
param entraIdClientSecret string?


var apimName = 'apima-${resourceSuffix}'
var keyVaultSecretsUserRoleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'
var keyVaultCertificatesOfficer = 'a4417e6f-fecd-4de8-b567-7b0420556985'

var hostNameConfigurations = [
  {
    type: 'Proxy'
    hostName: 'api.${apimCustomDomainName}'
    defaultSslBinding: true
    negotiateClientCertificate: false
    keyVaultId: certificateSecretUriWithoutVersion
  }
  {
    type: 'DeveloperPortal'
    hostName: 'developer.${apimCustomDomainName}'
    defaultSslBinding: false
    negotiateClientCertificate: false
    keyVaultId: certificateSecretUriWithoutVersion
  }
  {
    type: 'Management'
    hostName: 'management.${apimCustomDomainName}'
    defaultSslBinding: false
    negotiateClientCertificate: false
    keyVaultId: certificateSecretUriWithoutVersion
  }
]

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: primaryRegionSettings.location
  identity: {
    type: 'SystemAssigned'
  }
  sku:{
    capacity: primaryRegionSettings.apimRegionalSettings.skuCapacity
    name: skuName
  }
  zones: primaryRegionSettings.apimRegionalSettings.?availabilityZones
  properties:{
    virtualNetworkType: 'Internal'
    publisherEmail: publisherEmail
    publisherName: publisherName
    publicIpAddressId: apimPublicIpId
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
    additionalLocations: [for (settings,i) in additionalRegionSettings: {
      location: settings.location
      sku: {
        name: skuName
        capacity: settings.apimRegionalSettings.skuCapacity
      }
      virtualNetworkConfiguration:{
        subnetResourceId: additionalRegionsNetworkingResources[i].apimSubnetid
      }
      publicIpAddressId: additionalRegionsNetworkingResources[i].apimPublicIpId
      zones: settings.apimRegionalSettings.?availabilityZones
    }]
    hostnameConfigurations: (deployCustomDnsNames ? hostNameConfigurations : json('null'))
  }
}

module kvRoleAssignmentsCert 'kvAppRoleAssignment.bicep' = if(deployCustomDnsNames == false) {
  name: 'kvRoleAssignmentsCert'
  scope: resourceGroup(keyVaultRG)
  params: {
    keyVaultName: keyVaultName
    principalId: apim.identity.principalId
    // Key Vault Certificates Officer
    roleId: keyVaultSecretsUserRoleDefinitionId
  }
}

module kvRoleAssignmentsSecret 'kvAppRoleAssignment.bicep' = if(deployCustomDnsNames == false) {
  name: 'kvRoleAssignmentsSecret'
  scope: resourceGroup(keyVaultRG)
  params: {
    keyVaultName: keyVaultName
    principalId: apim.identity.principalId
    // Key Vault Secrets User
    roleId: keyVaultCertificatesOfficer
  }
  dependsOn: [
    kvRoleAssignmentsCert
  ]
}

module globalPolicy 'apimConfig.bicep' = if(deployCustomDnsNames == false) {
  name: 'globalPolicy'
  params: {
    apimServiceName: apim.name
  }
}

resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2019-01-01' = if(deployCustomDnsNames == false) {
  parent: apim
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

resource applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2019-01-01' = if(deployCustomDnsNames == false) {
  parent: apim
  name: 'applicationinsights'
  properties: {
    loggerId: appInsightsLogger.id
    alwaysLog: 'allErrors'
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
  }
}

resource service_apima_rmo3_dev_uksouth_001_name_aad 'Microsoft.ApiManagement/service/identityProviders@2023-05-01-preview' = if (entraIdClientId != null && deployCustomDnsNames == false) {
  parent: apim
  name: 'entraId'
  properties: {
    clientId: entraIdClientId
    type: 'aad'
    authority: 'login.windows.net'
    allowedTenants: ['MngEnvMCAP124364.onmicrosoft.com']
    clientLibrary: 'MSAL-2'
    clientSecret: entraIdClientSecret
  }
}

output apimPrivateIpAddress string = apim.properties.privateIPAddresses[0]
output apimName string = apimName
