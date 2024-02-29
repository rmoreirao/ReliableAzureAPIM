import {networkingResourcesType, sharedResourcesType, apimRegionalSettingsType , locationSettingType} from '../bicepParamTypes.bicep'

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

param primaryRegionSettings locationSettingType

param additionalRegionSettings locationSettingType[]

param appInsightsName string
param appInsightsId string
param appInsightsInstrumentationKey string

param keyVaultName string
param keyVaultRG string

/*
 * Resources
*/

var apimName = 'apim-${resourceSuffix}'
var apimManagedIdentityId = 'identity-${apimName}'
var keyVaultSecretsUserRoleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'

resource apimIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:     apimManagedIdentityId
  location: primaryRegionSettings.location
}

module kvRoleAssignmentsCert 'kvAppRoleAssignment.bicep' = {
  name: 'kvRoleAssignmentsCert'
  scope: resourceGroup(keyVaultRG)
  params: {
    keyVaultName: keyVaultName
    managedIdentity: apimIdentity
    // Key Vault Certificates Officer
    roleId: keyVaultSecretsUserRoleDefinitionId
  }
}

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: primaryRegionSettings.location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${apimIdentity.id}': {}
    }
  }
  sku:{
    capacity: primaryRegionSettings.apimRegionalSettings.skuCapacity
    name: skuName
  }
  
  properties:{
    additionalLocations: [for settings in additionalRegionSettings: {
      location: settings.location
      sku: {
        name: skuName
        capacity: settings.apimRegionalSettings.skuCapacity
      }
    }]

    virtualNetworkType: 'Internal'
    publisherEmail: publisherEmail
    publisherName: publisherName
    publicIpAddressId: apimPublicIpId
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
  }
}

resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2019-01-01' = {
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

resource applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2019-01-01' = {
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

output apimPrivateIpAddress string = apim.properties.privateIPAddresses[0]
output apimName string = apimName
