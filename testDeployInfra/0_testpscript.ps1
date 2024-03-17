# If not there, create a file called secrets.ps1 in the same folder as this file
# The file must have the following environment variables defined:
# $env:VMVMPASSWORD = "your_vm_password"
# $env:DEVOPS_PAT = "your_devops_pat"
# $env:SUBSCRIPTION_ID = "subscription_id to deploy to"

./secrets.ps1

$BICEPPARAM_FILE = "main.multiregiondev.bicepparam"
$BICEPPARAM_TMP_FILE = "main.multiregiondev.tmp.bicepparam"
# $BICEPPARAM_FILE = "main.dev.bicepparam"
# $BICEPPARAM_TMP_FILE = "main.dev.tmp.bicepparam"
$LOCATION = "uksouth"
$DEPLOY_NAME="apimDeployment"

# delete a deployment
# az deployment sub  delete  --name testasedeployment

az account set --subscription $env:SUBSCRIPTION_ID

$current_dir = Get-Location
Set-Location "..\infra\bicep"

python bicepParamUpdate.py --bicep_param_filename $BICEPPARAM_FILE --bicep_param_output_filename $BICEPPARAM_TMP_FILE --new_devops_password $env:VMVMPASSWORD --new_pat $env:DEVOPS_PAT --new_jumpbox_password $env:VMVMPASSWORD

Set-Location $current_dir
az deployment sub create --subscription $env:SUBSCRIPTION_ID --location $LOCATION --name $DEPLOY_NAME$LOCATION --template-file ..\infra\bicep\main.bicep --parameters ..\infra\bicep\$BICEPPARAM_TMP_FILE --debug
