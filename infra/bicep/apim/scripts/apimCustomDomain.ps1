# .\apimCustomDomain.ps1 -apimServiceName "apima-hkdi1-dev-westeurope-001" -resourceGroupName "rg-apim-hkdi1-dev-westeurope-001" -keyVaultCertificateUri "https://kv-hkdi1-dev-westeurope.vault.azure.net/secrets/contoso-sandbox-apim-com/5d13b65776fc41d381fe71f5d07472c2" -developerPortalDnsName "developer.contoso-sandbox-apim.com" -managementDnsName "management.contoso-sandbox-apim.com" -apiGatewayDnsName "api.contoso-sandbox-apim.com"

param(
  [Parameter(Mandatory=$true)] [string]$apimServiceName,
  [Parameter(Mandatory=$true)] [string]$resourceGroupName,
  [Parameter(Mandatory=$true)] [string]$keyVaultCertificateUri,
  [Parameter(Mandatory=$false)] [string]$developerPortalDnsName,
  [Parameter(Mandatory=$false)] [string]$managementDnsName,
  [Parameter(Mandatory=$false)] [string]$apiGatewayDnsName
)

      $ErrorActionPreference = 'Stop'
      $DeploymentScriptOutputs = @{}

      $apim = Get-AzApiManagement -ResourceGroupName $resourceGroupName -Name $apimServiceName

      if (![string]::IsNullOrEmpty($developerPortalDnsName)) {
        Write-Output "Setting developer portal custom domain to $developerPortalDnsName"
        $apim.DeveloperPortalHostnameConfiguration = New-AzApiManagementCustomHostnameConfiguration -hostname $developerPortalDnsName -hostnameType DeveloperPortal -keyVaultId $keyVaultCertificateUri
      }

      if (![string]::IsNullOrEmpty($managementDnsName)) {
        Write-Output "Setting management custom domain to $managementDnsName"
        $apim.ManagementCustomHostnameConfiguration = New-AzApiManagementCustomHostnameConfiguration -hostname $managementDnsName -hostnameType Management -keyVaultId $keyVaultCertificateUri
      }

      if (![string]::IsNullOrEmpty($apiGatewayDnsName)) {
        Write-Output "Setting api gateway custom domain to $apiGatewayDnsName"
        $apim.ProxyCustomHostnameConfiguration = New-AzApiManagementCustomHostnameConfiguration -Hostname $apiGatewayDnsName -HostnameType Proxy -KeyVaultId $keyVaultCertificateUri
      }
      
      Write-Output "Updating APIM service $apimServiceName"
      Set-AzApiManagement -InputObject $apim -SystemAssignedIdentity