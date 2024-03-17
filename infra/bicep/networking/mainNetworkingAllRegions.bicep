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
param firewallSku 'Basic' | 'Standard'?
param firewallAvailabilityZones avalabilityZoneType[]?
param locationsSettings regionalSettingType[]
param publicIpAvailabilityZones avalabilityZoneType[]?
param deployResources bool = true

// Creation of this module is required to return the array of NetworkingResources - this could not be directly done on main.bicep

module networkingModule './networkingRegional.bicep' = [for (locationSetting,i) in locationsSettings: {
  name: 'networkingRegional${workloadName}${environment}${locationSetting.location}'
  params: {
    workloadName: workloadName
    environment: environment
    location: locationSetting.location
    vNetSettings: locationSetting.vNetSettings
    firewallSku: firewallSku
    firewallAvailabilityZones: firewallAvailabilityZones
    publicIpAvailabilityZones: publicIpAvailabilityZones
    deployResources: deployResources
  }
}]

output networkingResourcesArray networkingResourcesType[] = [for index in (range(0, length(locationsSettings))): networkingModule[index].outputs.resources]
