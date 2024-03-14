targetScope = 'resourceGroup'

param apimServiceName string
@secure()
param holidaysAPIApiKey string?
@secure()
param weatherAPIApiKey string?

module holidaysAPI 'apis/holidaysAPI/holidaysAPI.bicep' = if (holidaysAPIApiKey != null) {
  name: 'holidaysAPI'
  params: {
    apimServiceName: apimServiceName
    apiKey: holidaysAPIApiKey!
  }
}

module weatherAPI 'apis/weatherAPI/weatherAPI.bicep' = if (weatherAPIApiKey != null) {
  name: 'weatherAPI'
  params: {
    apimServiceName: apimServiceName
    apiKey: weatherAPIApiKey!
  }
}
