targetScope='subscription'

param location string = deployment().location
resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-test-tags'
  location:location
}

// module tag 'test3.bicep' = {
//   name: 'test3'
//   scope: resourceGroup(networkingRG.name)
//   params: {
    
//   }
// }

