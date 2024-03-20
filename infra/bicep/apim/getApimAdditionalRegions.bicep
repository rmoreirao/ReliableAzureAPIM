import {apimRegionalResourcesType} from '../bicepParamTypes.bicep'

param additionalLocations object[]?

var additionalLocationsAux = empty(additionalLocations) ? [] : additionalLocations

output additionalRegionResources apimRegionalResourcesType[] = [for additionalLocation in additionalLocationsAux!: {
  apimPrivateIpAddress:additionalLocation.privateIPAddresses[0]
  apimGatewayURL:additionalLocation.gatewayRegionalUrl
  apimDevPortalURL: null
  apimManagementBackendEndURL: null
}]

