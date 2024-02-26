import {networkingResourcesType, sharedResourcesType, apimRegionalSettingsType} from '../bicepParamTypes.bicep'

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

@description('The instance size of the APIM resource.')
param capacity int

@description('Location for Azure resources.')
param location string = resourceGroup().location

param appInsightsName string
param appInsightsId string
param appInsightsInstrumentationKey string

/*
 * Resources
*/

var apimName = 'apim-${resourceSuffix}'

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: location
  sku:{
    capacity: capacity
    name: skuName
  }
  properties:{
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
