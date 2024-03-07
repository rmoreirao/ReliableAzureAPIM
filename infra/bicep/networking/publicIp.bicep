import {vNetRegionalSettingsType, avalabilityZoneType} from '../bicepParamTypes.bicep'

param workloadName string
param environment string
param location string
param vNetSettings vNetRegionalSettingsType
param availabilityZones avalabilityZoneType[]?

var pipSku = {
  name: 'Standard'
  tier: 'Regional'
}

var apimPublicIPName = 'pip-apim-${workloadName}-${environment}-${location}' // 'publicIp'
var bastionPublicIPName = 'pip-bastion-${workloadName}-${environment}-${location}'
var appGatewayPublicIpName = 'pip-appgw-${workloadName}-${environment}-${location}'
var publicIPAddressNameFirewall = 'pip-firewall-${workloadName}-${environment}-${location}'
var publicIPAddressNameFirewallManagement = 'pip-firewmgmt-${workloadName}-${environment}-${location}'

resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
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

// Mind the PIP for bastion being Standard SKU, Static IP
resource pipBastion 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (vNetSettings.?bastionAddressPrefix != null) {
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

resource appGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
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

resource pipFw 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (vNetSettings.?firewallAddressPrefix != null) {
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

resource pipFwMgmt 'Microsoft.Network/publicIPAddresses@2020-07-01' = if (vNetSettings.?firewallManagementAddressPrefix != null) {
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

output appGatewayPublicIpId string = appGatewayPublicIP.id
output apimPublicIpId string = pip.id
output publicIpBastionId string? = vNetSettings.?bastionAddressPrefix != null ? pipBastion.id : null
output publicIpFirewallId string? = vNetSettings.?firewallAddressPrefix != null ? pipFw.id : null
output publicIpFirewallMgmtId string? = vNetSettings.?firewallManagementAddressPrefix != null ? pipFwMgmt.id : null
