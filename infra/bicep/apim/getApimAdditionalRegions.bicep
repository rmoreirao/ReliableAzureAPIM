import {apimRegionalResourcesType} from '../bicepParamTypes.bicep'

param additionalLocations object[]

output additionalRegionResources apimRegionalResourcesType[] = [for additionalLocation in additionalLocations: {
  apimPrivateIpAddress:additionalLocation.privateIPAddresses[0]
  apimGatewayURL:additionalLocation.gatewayRegionalUrl
  apimDevPortalURL: null
  apimManagementBackendEndURL: null
}]

