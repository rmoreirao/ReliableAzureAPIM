import {vNetRegionalSettingsType, regionalSettingType, networkingResourcesType, avalabilityZoneType} from '../bicepParamTypes.bicep'

@description('A short name for the workload being deployed alphanumberic only')
@maxLength(8)
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string
param firewallSku string
param firewallAvailabilityZones avalabilityZoneType[]?
param locationsSettings regionalSettingType[]
param publicIpAvailabilityZones avalabilityZoneType[]?

// Creation of this module is required to return the array of NetworkingResources - this could not be directly done on main.bicep

module networkingModule './mainNetworking.bicep' = [for (locationSetting,i) in locationsSettings: {
  name: 'networkingresources${workloadName}${environment}${locationSetting.location}'
  params: {
    workloadName: workloadName
    environment: environment
    location: locationSetting.location
    vNetSettings: locationSetting.vNetSettings
    firewallSku: firewallSku
    firewallAvailabilityZones: firewallAvailabilityZones
    publicIpAvailabilityZones: publicIpAvailabilityZones
  }
}]

output networkingResourcesArray networkingResourcesType[] = [for index in (range(0, length(locationsSettings))): networkingModule[index].outputs.resources]
