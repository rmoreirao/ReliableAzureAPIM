#  .\appGatewayCertToKv.ps1 -certType "selfsigned" -vaultName "kv-rmo8-dev-uksouth-001" -domainName "contoso-sandbox-apim.com" -certificateName "apicontososandboxapimcom"


param(
      [string] [Parameter(Mandatory=$true)] $vaultName,
      [string] [Parameter(Mandatory=$true)] $certificateName,
      [string] [Parameter(Mandatory=$true)] $domainName,
      [string] [Parameter(Mandatory=$false)] $certPwd,
      [string] [Parameter(Mandatory=$false)] $certDataString,
      [string] [Parameter(Mandatory=$true)] $certType
      )

      $ErrorActionPreference = 'Stop'
      $DeploymentScriptOutputs = @{}
      if ($certType -eq 'selfsigned') {
        Write-Host 'Starting creation of certificate $certificateName in vault $vaultName...'

        $policy = New-AzKeyVaultCertificatePolicy -SubjectName "CN=$domainName" -DnsName "api.$domainName", "developer.$domainName", "management.$domainName"  -IssuerName Self -ValidityInMonths 12 -Verbose
        
        # private key is added as a secret that can be retrieved in the ARM template
        Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose

        $newCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName

        # it takes a few seconds for KeyVault to finish
        $tries = 0
        do {
          Write-Host 'Waiting for certificate creation completion...'
          Start-Sleep -Seconds 10
          $operation = Get-AzKeyVaultCertificateOperation -VaultName $vaultName -Name $certificateName
          $tries++

          if ($operation.Status -eq 'failed')
          {
          throw 'Creating certificate $certificateName in vault $vaultName failed with error $($operation.ErrorMessage)'
          }

          if ($tries -gt 120)
          {
          throw 'Timed out waiting for creation of certificate $certificateName in vault $vaultName'
          }
        } while ($operation.Status -ne 'completed')	

        Write-Host 'Certificate creation completed.'
      }
      else {
        $ss = Convertto-SecureString -String $certPwd -AsPlainText -Force; 
        Import-AzKeyVaultCertificate -Name $certificateName -VaultName $vaultName -CertificateString $certDataString -Password $ss
      }