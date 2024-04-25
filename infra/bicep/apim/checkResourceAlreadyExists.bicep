targetScope = 'resourceGroup'

@description('Resource name to check in current scope (resource group)')
param resourceName string

@description('Resource ID of user managed identity with reader permissions in current scope')
param identityId string

param location string = resourceGroup().location
param utcValue string = utcNow()
param resourceGroupName string = resourceGroup().name

// The script below performs an 'az resource list' command to determine whether a resource exists
resource resource_exists_script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'resource_exists'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.15.0'
    timeout: 'PT10M'
    arguments: '\'${resourceGroupName}\' \'${resourceName}\''
    scriptContent: '''
      RESOURCE_EXISTE="false"

      output=$(az resource list --resource-group ${resourceGroupName} --name ${resourceName})
      
      if echo "$output" | grep -q "id"; then
          RESOURCE_EXISTS="true"
      else
          RESOURCE_EXISTS="false"
      fi
      
      JSON_STRING=$(jq -n \
            --arg resource_exists "$RESOURCE_EXISTS" \
            '{RESOURCE_EXISTS: $resource_exists}' )
      
      echo $JSON_STRING

      echo $JSON_STRING > $AZ_SCRIPTS_OUTPUT_PATH

    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output exists bool = resource_exists_script.properties.outputs.RESOURCE_EXISTS == 'true'
