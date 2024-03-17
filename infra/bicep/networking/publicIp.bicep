import {vNetRegionalSettingsType, avalabilityZoneType} from '../bicepParamTypes.bicep'

param workloadName string
param environment string
param location string
param vNetSettings vNetRegionalSettingsType
param availabilityZones avalabilityZoneType[]?
param deployResources bool

var pipSku = {
  name: 'Standard'
  tier: 'Regional'
}

var apimPublicIPName = 'pip-apim-${workloadName}-${environment}-${location}' // 'publicIp'
var bastionPublicIPName = 'pip-bastion-${workloadName}-${environment}-${location}'
var appGatewayPublicIpName = 'pip-appgw-${workloadName}-${environment}-${location}'
var publicIPAddressNameFirewall = 'pip-firewall-${workloadName}-${environment}-${location}'
var publicIPAddressNameFirewallManagement = 'pip-firewmgmt-${workloadName}-${environment}-${location}'

resource pipApim 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (deployResources) {
  name: apimPublicIPName
  location: location
  sku: pipSku
  zones:availabilityZones
  
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${apimPublicIPName}-${uniqueString(resourceGroup().id)}')
    }
  } 
}

resource pipApimExisting 'Microsoft.Network/publicIPAddresses@2020-07-01' existing = if (!deployResources) {
  name: apimPublicIPName
}

// Mind the PIP for bastion being Standard SKU, Static IP
resource pipBastion 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (deployResources && vNetSettings.?bastionAddressPrefix != null) {
  name: bastionPublicIPName
  location: location
  sku: pipSku
  zones:availabilityZones
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${bastionPublicIPName}-${uniqueString(resourceGroup().id)}')
    }
  }  
}

resource pipBastionExisting 'Microsoft.Network/publicIPAddresses@2020-07-01' existing = if (!deployResources && vNetSettings.?bastionAddressPrefix != null) {
  name: bastionPublicIPName
}

resource appGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (deployResources) {
  name: appGatewayPublicIpName
  location: location
  sku: pipSku
  zones:availabilityZones
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower('${appGatewayPublicIpName}-${uniqueString(resourceGroup().id)}')
    }
  }
}

resource appGatewayPublicIPExisting 'Microsoft.Network/publicIPAddresses@2020-07-01' existing = if (!deployResources) {
  name: appGatewayPublicIpName
}

resource pipFw 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (deployResources && vNetSettings.?firewallAddressPrefix != null) {
  name: publicIPAddressNameFirewall
  location: location
  sku: pipSku
  zones:availabilityZones
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${publicIPAddressNameFirewall}-${uniqueString(resourceGroup().id)}')
    }
  } 
}

resource pipFwExisting 'Microsoft.Network/publicIPAddresses@2020-07-01' existing = if (!deployResources && vNetSettings.?firewallAddressPrefix != null) {
  name: publicIPAddressNameFirewall
}

resource pipFwMgmt 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (deployResources && vNetSettings.?firewallManagementAddressPrefix != null) {
  name: publicIPAddressNameFirewallManagement
  location: location
  sku: pipSku
  zones:availabilityZones
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${publicIPAddressNameFirewallManagement}-${uniqueString(resourceGroup().id)}')
    }
  } 
}

resource pipFwMgmtExisting 'Microsoft.Network/publicIPAddresses@2020-07-01' existing = if (!deployResources && vNetSettings.?firewallManagementAddressPrefix != null) {
  name: publicIPAddressNameFirewallManagement
}

output appGatewayPublicIpId string = deployResources ? appGatewayPublicIP.id : appGatewayPublicIPExisting.id
output apimPublicIpId string = deployResources ? pipApim.id : pipApimExisting.id
output publicIpBastionId string? = vNetSettings.?bastionAddressPrefix != null ? (deployResources ? pipBastion.id : pipBastionExisting.id) : null
output publicIpFirewallId string? = vNetSettings.?firewallAddressPrefix != null ? (deployResources ? pipFw.id : pipFwExisting.id) : null
output publicIpFirewallMgmtId string? = vNetSettings.?firewallManagementAddressPrefix != null ? (deployResources ? pipFwMgmt.id : pipFwMgmtExisting.id) : null
