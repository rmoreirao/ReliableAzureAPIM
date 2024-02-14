# Use https://appgwbackendcertgenerator.azurewebsites.net/ to generate the 4 certificates required
# get the password certificates from the zip files



# These variables must be changed.
$subscriptionId = "afb8f550-216d-4848-b6f1-73b1bbf58f1e"      # GUID of your Azure subscription
$domain = "contoso.net"                                       # The custom domain for your certificate
$apimServiceName = "apim-contoso-rmor"                             # API Management service instance name, must be globally unique    
$apimDomainNameLabel = $apimServiceName                       # Domain name label for API Management's public IP address, must be globally unique
$apimAdminEmail = "rmoreirao@microsoft.com"                         # Administrator's email address - use your email address

$gatewayHostname = "api.$domain"                              # API gateway host
$portalHostname = "portal.$domain"                            # API developer portal host
$managementHostname = "management.$domain"                    # API management endpoint host

$baseCertPath = "C:\Users\Contoso\"                           # The base path where all certificates are stored
$trustedRootCertCerPath = "C:\Temp\APIMGatewayAppGateway\certificates_contoso_net\trustedroot.cer"    # Full path to contoso.net trusted root .cer file
$gatewayCertPfxPath = "C:\Temp\APIMGatewayAppGateway\certificates_api_contoso_net\server.pfx"            # Full path to api.contoso.net .pfx file
$portalCertPfxPath = "C:\Temp\APIMGatewayAppGateway\certificates_portal_contoso_net\server.pfx"              # Full path to portal.contoso.net .pfx file
$managementCertPfxPath = "C:\Temp\APIMGatewayAppGateway\certificates_management_contoso_net\server.pfx"      # Full path to management.contoso.net .pfx file

$gatewayCertPfxPassword = "5dF62VMjiq8umXk1"            # Password for api.contoso.net pfx certificate
$portalCertPfxPassword = "IN2BPVqRROl6lgPe"             # Password for portal.contoso.net pfx certificate
$managementCertPfxPassword = "fW9BTptxIuhDbz74"         # Password for management.contoso.net pfx certificate


# These variables may be changed.
$resGroupName = "rg-apim-agw"                                 # Resource group name that will hold all assets
$location = "West Europe"                                         # Azure region that will hold all assets
$apimOrganization = "Contoso"                                 # Organization name    
$appgwName = "agw-contoso"                                    # The name of the Application Gateway

# If Az PowerShell module is not installed, install it: Install-Module -Name Az -AllowClobber -Scope CurrentUser

Connect-AzAccount

Get-AzSubscription -Subscriptionid $subscriptionId | Select-AzSubscription

New-AzResourceGroup -Name $resGroupName -Location $location

$appGwRule1 = New-AzNetworkSecurityRuleConfig -Name appgw-in -Description "AppGw inbound" `
    -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix `
    GatewayManager -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 65200-65535

$appGwRule2 = New-AzNetworkSecurityRuleConfig -Name appgw-in-internet -Description "AppGw inbound Internet" `
    -Access Allow -Protocol "TCP" -Direction Inbound -Priority 110 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443

$appGwNsg = New-AzNetworkSecurityGroup -ResourceGroupName $resGroupName -Location $location -Name `
    "nsg-agw" -SecurityRules $appGwRule1, $appGwRule2

$apimRule1 = New-AzNetworkSecurityRuleConfig -Name APIM-Management -Description "APIM inbound" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix ApiManagement `
    -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3443

$apimRule2 = New-AzNetworkSecurityRuleConfig -Name AllowAppGatewayToAPIM -Description "Allows inbound App Gateway traffic to APIM" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix "10.0.0.0/24" `
    -SourcePortRange * -DestinationAddressPrefix "10.0.1.0/24" -DestinationPortRange 443

$apimRule3 = New-AzNetworkSecurityRuleConfig -Name AllowAzureLoadBalancer -Description "Allows inbound Azure Infrastructure Load Balancer traffic to APIM" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix AzureLoadBalancer `
    -SourcePortRange * -DestinationAddressPrefix "10.0.1.0/24" -DestinationPortRange 6390
    
$apimRule4 = New-AzNetworkSecurityRuleConfig -Name AllowKeyVault -Description "Allows outbound traffic to Azure Key Vault" `
    -Access Allow -Protocol Tcp -Direction Outbound -Priority 100 -SourceAddressPrefix "10.0.1.0/24" `
    -SourcePortRange * -DestinationAddressPrefix AzureKeyVault -DestinationPortRange 443

$apimNsg = New-AzNetworkSecurityGroup -ResourceGroupName $resGroupName -Location $location -Name `
    "nsg-apim" -SecurityRules $apimRule1, $apimRule2, $apimRule3, $apimRule4

$appGatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name "appGatewaySubnet" -NetworkSecurityGroup $appGwNsg -AddressPrefix "10.0.0.0/24"

$apimSubnet = New-AzVirtualNetworkSubnetConfig -Name "apimSubnet" -NetworkSecurityGroup $apimNsg -AddressPrefix "10.0.1.0/24"

$vnet = New-AzVirtualNetwork -Name "vnet-contoso" -ResourceGroupName $resGroupName `
  -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $appGatewaySubnet,$apimSubnet

$appGatewaySubnetData = $vnet.Subnets[0]
$apimSubnetData = $vnet.Subnets[1]

$apimPublicIpAddressId = New-AzPublicIpAddress -ResourceGroupName $resGroupName -name "pip-apim" -location $location `
    -AllocationMethod Static -Sku Standard -Force -DomainNameLabel $apimDomainNameLabel

$apimVirtualNetwork = New-AzApiManagementVirtualNetwork -SubnetResourceId $apimSubnetData.Id

$apimService = New-AzApiManagement -ResourceGroupName $resGroupName -Location $location -Name $apimServiceName -Organization $apimOrganization `
    -AdminEmail $apimAdminEmail -VirtualNetwork $apimVirtualNetwork -VpnType "Internal" -Sku "Developer" -PublicIpAddressId $apimPublicIpAddressId.Id

$certGatewayPwd = ConvertTo-SecureString -String $gatewayCertPfxPassword -AsPlainText -Force
$certPortalPwd = ConvertTo-SecureString -String $portalCertPfxPassword -AsPlainText -Force
$certManagementPwd = ConvertTo-SecureString -String $managementCertPfxPassword -AsPlainText -Force

$gatewayHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $gatewayHostname `
  -HostnameType Proxy -PfxPath $gatewayCertPfxPath -PfxPassword $certGatewayPwd

$portalHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $portalHostname `
  -HostnameType DeveloperPortal -PfxPath $portalCertPfxPath -PfxPassword $certPortalPwd
  
$managementHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $managementHostname `
  -HostnameType Management -PfxPath $managementCertPfxPath -PfxPassword $certManagementPwd

$apimService.ProxyCustomHostnameConfiguration = $gatewayHostnameConfig
$apimService.PortalCustomHostnameConfiguration = $portalHostnameConfig
$apimService.ManagementCustomHostnameConfiguration = $managementHostnameConfig

Set-AzApiManagement -InputObject $apimService

$myZone = New-AzPrivateDnsZone -Name $domain -ResourceGroupName $resGroupName 
$link = New-AzPrivateDnsVirtualNetworkLink -ZoneName $domain `
  -ResourceGroupName $resGroupName -Name "mylink" `
  -VirtualNetworkId $vnet.id

  $apimIP = $apimService.PrivateIPAddresses[0]

  New-AzPrivateDnsRecordSet -Name api -RecordType A -ZoneName $domain `
    -ResourceGroupName $resGroupName -Ttl 3600 `
    -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $apimIP)

  New-AzPrivateDnsRecordSet -Name portal -RecordType A -ZoneName $domain `
    -ResourceGroupName $resGroupName -Ttl 3600 `
    -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $apimIP)
  
    New-AzPrivateDnsRecordSet -Name management -RecordType A -ZoneName $domain `
    -ResourceGroupName $resGroupName -Ttl 3600 `
    -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $apimIP)

$publicip = New-AzPublicIpAddress -ResourceGroupName $resGroupName `
    -name "pip-appgateway" -location $location -AllocationMethod Static -Sku Standard

$gipconfig = New-AzApplicationGatewayIPConfiguration -Name "gatewayIP01" -Subnet $appGatewaySubnetData

$fp01 = New-AzApplicationGatewayFrontendPort -Name "port01"  -Port 443

$fipconfig01 = New-AzApplicationGatewayFrontendIPConfig -Name "frontend1" -PublicIPAddress $publicip

$certGateway = New-AzApplicationGatewaySslCertificate -Name "gatewaycert" `
  -CertificateFile $gatewayCertPfxPath -Password $certGatewayPwd

$certPortal = New-AzApplicationGatewaySslCertificate -Name "portalcert" `
  -CertificateFile $portalCertPfxPath -Password $certPortalPwd

  $certManagement = New-AzApplicationGatewaySslCertificate -Name "managementcert" `
  -CertificateFile $managementCertPfxPath -Password $certManagementPwd

$gatewayListener = New-AzApplicationGatewayHttpListener -Name "gatewaylistener" `
  -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 `
  -SslCertificate $certGateway -HostName $gatewayHostname -RequireServerNameIndication true

$portalListener = New-AzApplicationGatewayHttpListener -Name "portallistener" `
  -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 `
  -SslCertificate $certPortal -HostName $portalHostname -RequireServerNameIndication true

  $managementListener = New-AzApplicationGatewayHttpListener -Name "managementlistener" `
  -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 `
  -SslCertificate $certManagement -HostName $managementHostname -RequireServerNameIndication true

$apimGatewayProbe = New-AzApplicationGatewayProbeConfig -Name "apimgatewayprobe" `
  -Protocol "Https" -HostName $gatewayHostname -Path "/status-0123456789abcdef" `
  -Interval 30 -Timeout 120 -UnhealthyThreshold 8

$apimPortalProbe = New-AzApplicationGatewayProbeConfig -Name "apimportalprobe" `
  -Protocol "Https" -HostName $portalHostname -Path "/signin" `
  -Interval 60 -Timeout 300 -UnhealthyThreshold 8

  $apimManagementProbe = New-AzApplicationGatewayProbeConfig -Name "apimmanagementprobe" `
  -Protocol "Https" -HostName $managementHostname -Path "/ServiceStatus" `
  -Interval 60 -Timeout 300 -UnhealthyThreshold 8

$trustedRootCert = New-AzApplicationGatewayTrustedRootCertificate -Name "allowlistcert1" -CertificateFile $trustedRootCertCerPath

$apimPoolGatewaySetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolGatewaySetting" `
  -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimGatewayProbe `
  -TrustedRootCertificate $trustedRootCert -PickHostNameFromBackendAddress -RequestTimeout 180

$apimPoolPortalSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolPortalSetting" `
  -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimPortalProbe `
  -TrustedRootCertificate $trustedRootCert -PickHostNameFromBackendAddress -RequestTimeout 180

  $apimPoolManagementSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolManagementSetting" `
  -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimManagementProbe `
  -TrustedRootCertificate $trustedRootCert -PickHostNameFromBackendAddress -RequestTimeout 180

  $apimGatewayBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "gatewaybackend" `
  -BackendFqdns $gatewayHostname

  $apimPortalBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "portalbackend" `
  -BackendFqdns $portalHostname

$apimManagementBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "managementbackend" `
  -BackendFqdns $managementHostname

$gatewayRule = New-AzApplicationGatewayRequestRoutingRule -Name "gatewayrule" `
  -RuleType Basic -HttpListener $gatewayListener -BackendAddressPool $apimGatewayBackendPool `
  -BackendHttpSettings $apimPoolGatewaySetting -Priority 10

  $portalRule = New-AzApplicationGatewayRequestRoutingRule -Name "portalrule" `
  -RuleType Basic -HttpListener $portalListener -BackendAddressPool $apimPortalBackendPool `
  -BackendHttpSettings $apimPoolPortalSetting -Priority 20

  $managementRule = New-AzApplicationGatewayRequestRoutingRule -Name "managementrule" `
  -RuleType Basic -HttpListener $managementListener -BackendAddressPool $apimManagementBackendPool `
  -BackendHttpSettings $apimPoolManagementSetting -Priority 30

  $sku = New-AzApplicationGatewaySku -Name "WAF_v2" -Tier "WAF_v2" -Capacity 2

  $config = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Prevention"

  $policy = New-AzApplicationGatewaySslPolicy -PolicyType Predefined -PolicyName AppGwSslPolicy20220101

  $appgw = New-AzApplicationGateway -Name $appgwName -ResourceGroupName $resGroupName -Location $location `
  -BackendAddressPools $apimGatewayBackendPool,$apimPortalBackendPool,$apimManagementBackendPool `
  -BackendHttpSettingsCollection $apimPoolGatewaySetting, $apimPoolPortalSetting, $apimPoolManagementSetting `
  -FrontendIpConfigurations $fipconfig01 -GatewayIpConfigurations $gipconfig -FrontendPorts $fp01 `
  -HttpListeners $gatewayListener,$portalListener,$managementListener `
  -RequestRoutingRules $gatewayRule,$portalRule,$managementRule `
  -Sku $sku -WebApplicationFirewallConfig $config -SslCertificates $certGateway,$certPortal,$certManagement `
  -TrustedRootCertificate $trustedRootCert -Probes $apimGatewayProbe,$apimPortalProbe,$apimManagementProbe `
  -SslPolicy $policy