resourceGroupName=${1:?"Missing resourceGroupName."}
resourceName=${2:?"Missing resourceName."}
subscription=${3:?"Missing subscription."}

output=$(az resource list --resource-group ${resourceGroupName} --name ${resourceName} --subscription ${subscription} 2>&1)

if [ $? -ne 0 ]; then
    echo "Error executing command: $output"
else 
    echo "Command executed successfully."
fi

echo "resourceGroupName: $resourceGroupName"
echo "resourceName: $resourceName"
echo "subscription: $subscription"
echo "Output: $output"

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
