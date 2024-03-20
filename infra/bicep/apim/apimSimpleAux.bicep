import {networkingResourcesType, sharedResourcesType, apimRegionalSettingsType , regionalSettingType, apimRegionalResourcesType} from '../bicepParamTypes.bicep'

param deployResources bool
param existsApim bool
param apimName string
param primaryRegionSettings regionalSettingType
param publisherEmail string
param publisherName string
param skuName string
param apimPublicIpId string
param apimSubnetId string

// Initially deploy a smaller APIM instance to create the System Assigned Managed Identity
// Currently APIM can only access KeyVault via VNET integration using System Assigned Managed Identity
// So we need to deploy the APIM instance first to get the Managed Identity and then deploy the custom domain name
resource apimAux 'Microsoft.ApiManagement/service@2021-08-01' = if (deployResources && !existsApim) {
  name: apimName
  location: primaryRegionSettings.location
  identity: {
    type: 'SystemAssigned'
  }
  sku:{
    capacity: primaryRegionSettings.apimRegionalSettings.skuCapacity
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

resource apimAuxExisting 'Microsoft.ApiManagement/service@2021-08-01' existing = if (deployResources && existsApim) {
  name: apimName
}

output apimIdentityPrincipalId string = deployResources && !existsApim ? apimAux.identity.principalId : apimAuxExisting.identity.principalId
