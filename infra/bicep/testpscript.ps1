$LOCATION = "uksouth"
$DEPLOY_NAME="rmor4"

# delete a deployment
# az deployment sub  delete  --name testasedeployment

# set current subscription to 68d83f24-120a-47bf-a523-0a42e8e6cad1
az account set --subscription 68d83f24-120a-47bf-a523-0a42e8e6cad1

# deploy the bicep file directly

az deployment sub create --location $LOCATION --name $DEPLOY_NAME --template-file main.bicep --parameters workloadName=$DEPLOY_NAME environment=dev CICDAgentType=azuredevops accountName=rmoreiraoms personalAccessToken=ssjuzjzpmub77yoo4sctdxw4scayyg754aqpoxs253e2hw25sbva
