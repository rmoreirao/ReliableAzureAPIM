param location string
param resourceGroup string
param azureFirewallName string
param azureFirewallTier string
param vnetName string
param vnetAddressSpace string
param vnetAddressSpaceV6 string
param subnetAddressSpace string
param subnetAddressSpaceV6 string
param zones array
param azureFirewallManagementSubnet string
param tunnelingSubnetAddressSpace string
param managementPublicIpAddressName string
param managementPublicIpZones array
param publicIpAddressName string
param publicIpZones array
param publicIpV6AddressName string

var networkApiVersion = '?api-version=2019-09-01'

resource managementPublicIpAddress 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: managementPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: managementPublicIpZones
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {}
}

resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: publicIpZones
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  tags: {}
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressSpace]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefixes: null
          addressPrefix: subnetAddressSpace
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: tunnelingSubnetAddressSpace
        }
      }
    ]
  }
  tags: {}
  dependsOn: []
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: azureFirewallName
  location: location
  zones: zones
  properties: {
    ipConfigurations: [
      {
        name: publicIpAddressName
        properties: {
          subnet: {
            id: resourceId(
              resourceGroup,
              'Microsoft.Network/virtualNetworks/subnets',
              vnetName,
              'AzureFirewallSubnet'
            )
          }
          publicIPAddress: {
            id: resourceId(
              resourceGroup,
              'Microsoft.Network/publicIPAddresses',
              publicIpAddressName
            )
          }
        }
      }
    ]
    sku: {
      tier: azureFirewallTier
    }
    managementIpConfiguration: {
      name: managementPublicIpAddressName
      properties: {
        subnet: {
          id: resourceId(
            resourceGroup,
            'Microsoft.Network/virtualNetworks/subnets',
            vnetName,
            'AzureFirewallManagementSubnet'
          )
        }
        publicIPAddress: {
          id: resourceId(
            resourceGroup,
            'Microsoft.Network/publicIpAddresses',
            managementPublicIpAddressName
          )
        }
      }
    }
    firewallPolicy: {
      id: '/subscriptions/68d83f24-120a-47bf-a523-0a42e8e6cad1/resourcegroups/rg-basic-firewall/providers/Microsoft.Network/firewallPolicies/basicfirewall'
    }
  }
  tags: {}
  dependsOn: [
    resourceId(
      resourceGroup,
      'Microsoft.Network/publicIpAddresses',
      managementPublicIpAddressName
    )
    resourceId(
      resourceGroup,
      'Microsoft.Network/publicIpAddresses',
      publicIpAddressName
    )
    resourceId(resourceGroup, 'Microsoft.Network/virtualNetworks', vnetName)
  ]
}
