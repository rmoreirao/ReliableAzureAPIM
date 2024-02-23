
param workloadName string
param environment string
param location string


var apimPublicIPName = 'pip-apim-${workloadName}-${environment}-${location}' // 'publicIp'
var bastionPublicIPName = 'pip-bastion-${workloadName}-${environment}-${location}'
var appGatewayPublicIpName = 'pip-appgw-${workloadName}-${environment}-${location}'



resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: apimPublicIPName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${apimPublicIPName}-${uniqueString(resourceGroup().id)}')
    }
  } 
  
}

// Mind the PIP for bastion being Standard SKU, Static IP
resource pipBastion 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: bastionPublicIPName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${bastionPublicIPName}-${uniqueString(resourceGroup().id)}')
    }
  }  
}

resource appGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2019-09-01' = {
  name: appGatewayPublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower('${appGatewayPublicIpName}-${uniqueString(resourceGroup().id)}')
    }
  }
}

output appGatewayPublicIpId string = appGatewayPublicIP.id
output apimPublicIpId string = pip.id
output publicIpBastionId string = pipBastion.id
