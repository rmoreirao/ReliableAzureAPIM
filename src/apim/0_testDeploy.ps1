# If not there, create a file called secrets.ps1 in the same folder as this file
# The file must have the following environment variables defined:
# $env:WEATHERAPI_APIKEY = "your_vm_password"
# $env:HOLIDAYS_APIKEY = "your_vm_password"
# $env:SUBSCRIPTION_ID = "subscription_id to deploy to"

./secrets.ps1

# Parameters
$resourceGroupName = "rg-apim-hkdi2-dev-westeurope-001"
$apimServiceName = "apima-hkdi2-dev-westeurope-001"

az account set --subscription $env:SUBSCRIPTION_ID

# Deploy the Bicep file to the resource group
az deployment group create `
  --name "apimDeployment" `
  --resource-group $resourceGroupName `
  --template-file "apimConfig.bicep" `
  --parameters apimServiceName=$apimServiceName `
  --subscription $env:SUBSCRIPTION_ID `
  --parameters holidaysAPIApiKey=$env:HOLIDAYS_APIKEY `
  weatherAPIApiKey=$env:WEATHERAPI_APIKEY `
  --debug




