# If not there, create a file called secrets.ps1 in the same folder as this file
# The file must have the following environment variables defined:
# $env:VMVMPASSWORD = "your_vm_password"
# $env:DEVOPS_PAT = "your_devops_pat"

./secrets.ps1

$BICEPPARAM_FILE = "main.dev.bicepparam"
$BICEPPARAM_TMP_FILE = "main.dev.tmp.bicepparam"
$LOCATION = "westeurope"
$DEPLOY_NAME="apimDeployment"


# delete a deployment
# az deployment sub  delete  --name testasedeployment


# set current subscription to 68d83f24-120a-47bf-a523-0a42e8e6cad1

# DI
az account set --subscription 2d172aeb-b927-43ec-9808-8c9585119364 

# Non-Prod
# az account set --subscription afb8f550-216d-4848-b6f1-73b1bbf58f1e


# deploy the bicep file directly

# az deployment sub create --location $LOCATION --name $DEPLOY_NAME --template-file ..\infra\bicep\main.bicep --parameters workloadName=$DEPLOY_NAME environment=dev CICDAgentType=azuredevops accountName="https://dev.azure.com/rmoreiraoms" personalAccessToken=ssjuzjzpmub77yoo4sctdxw4scayyg754aqpoxs253e2hw25sbva

# az deployment sub create --location $LOCATION --name $DEPLOY_NAME --template-file ..\infra\bicep\main.bicep --parameters workloadName=$DEPLOY_NAME environment=dev CICDAgentType=azuredevops 

$current_dir = Get-Location
Set-Location "..\infra\bicep"

python bicepParamUpdate.py --bicep_param_filename $BICEPPARAM_FILE --bicep_param_output_filename $BICEPPARAM_TMP_FILE --new_devops_password $env:VMVMPASSWORD --new_pat $env:DEVOPS_PAT --new_jumpbox_password $env:VMVMPASSWORD

Set-Location $current_dir
az deployment sub create --subscription 2d172aeb-b927-43ec-9808-8c9585119364 --location $LOCATION --name $DEPLOY_NAME$LOCATION --template-file ..\infra\bicep\main.bicep --parameters ..\infra\bicep\$BICEPPARAM_TMP_FILE --debug


# New-AzSubscriptionDeployment `
#     -Location $LOCATION `
#     -Name $DEPLOY_NAME `
#     -TemplateFile "..\infra\bicep\main.bicep" `
#     -TemplateParameterFile "..\infra\bicep\main.dev.bicepparam" `
#     -devOpsVmPassword = $DEVOPS_VMPASSWORD `
#     -devOpsPersonalAccessToken = $DEVOPS_PAT `
#     -Verbose
    
# python ..\infra\bicep\bicepParamUpdate.py --bicep_param_filename "main.dev.bicepparam" --bicep_param_output_filename "main.dev.bicepparam.tmp" --new_password "new_password_value" --new_pat "new_pat_value"