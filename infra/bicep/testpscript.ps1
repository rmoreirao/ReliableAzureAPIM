# $LOCATION = "westeurope"
# $BICEP_FILE="main.bicep"

# delete a deployment
# az deployment sub  delete  --name testasedeployment

# set current subscription to 68d83f24-120a-47bf-a523-0a42e8e6cad1
az account set --subscription 68d83f24-120a-47bf-a523-0a42e8e6cad1

# deploy the bicep file directly

az deployment sub create --location westeurope --name rmor2 --template-file main.bicep --parameters workloadName=rmor2 environment=dev
