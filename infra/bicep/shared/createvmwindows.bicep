param location string

@description('The full id string identifying the target subnet for the VM')
param subnetId string

@description('Disk type of the IS disk')
param osDiskType string = 'StandardSSD_LRS'

@description('Valid SKU indicator for the VM')
param vmSize string = 'Standard_D2s_v3'

@description('The user name to be used as the Administrator for all VMs created by this deployment')
param username string

@description('The password for the Administrator user for all VMs created by this deployment')
@secure()
param password string

@description('Windows OS Version indicator')
param windowsOSVersion string

@description('Name of the VM to be created')
param vmName string

@description('Indicator to guide whether the CI/CD agent script should be run or not')
param deployAgent bool=false

@description('The Azure DevOps or GitHub account name')
param accountName string=''

@description('The personal access token to connect to Azure DevOps or Github')
@secure()
param personalAccessToken string=''

@description('The name Azure DevOps or GitHub pool for this build agent to join. Use \'Default\' if you don\'t have a separate pool.')
param poolName string = 'Default'

@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param CICDAgentType string

@description('The base URI where the CI/CD agent artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')

param artifactsLocation string = 'https://raw.githubusercontent.com/Azure/apim-landing-zone-accelerator/main/reference-implementations/AppGW-IAPIM-Func/bicep/shared/agentsetup.ps1'
// Variables
var agentName = 'agent-${vmName}'
var nicName = '${vmName}-nic'

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

// Create the vm
resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: vmName
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: username
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// deploy CI/CD agent, if required
resource vm_CustomScript 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = if (deployAgent) {
  parent: vm
  name: 'CustomScript'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      fileUris: [
        artifactsLocation
      ]
      // In case of issues / debug
      // commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -Command ./agentsetup.ps1 -url ${accountName} -pat ${personalAccessToken} -agent ${agentName} -pool ${poolName} -agenttype ${CICDAgentType} '
    }
    protectedSettings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -Command ./agentsetup.ps1 -url ${accountName} -pat ${personalAccessToken} -agent ${agentName} -pool ${poolName} -agenttype ${CICDAgentType} '
    }
  }
}

// outputs
output id string = vm.id
