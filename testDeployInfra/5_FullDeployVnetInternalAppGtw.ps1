# https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway
# https://docs.chunliu.me/apim/integration-apim-vnet-internal.html

$deploySuffix = "rmorei"

$certPassword="CertificatePassword98765@@**"
$baseCertPath = "C:\temp\ApimCertificates\"

# These variables must be changed.
$domain = "contoso.net"                                       # The custom domain for your certificate
$apimServiceName = "apim-contoso-${deploySuffix}"                             # API Management service instance name, must be globally unique    
$apimDomainNameLabel = "${apimServiceName}"                       # Domain name label for API Management's public IP address, must be globally unique
$apimAdminEmail = "rmoreirao@gmail.com"                         # Administrator's email address - use your email address

$gatewayHostname = "api.$domain"                              # API gateway host
$portalHostname = "portal.$domain"                            # API developer portal host
$managementHostname = "management.$domain"                    # API management endpoint host

# This was manually extracted from the PFX certificate using Key Explorer on the 509 format - to be automated! 

$trustedRootCertCerPath = "${baseCertPath}contoso-signing-root.cer"    # Full path to contoso.net trusted root .cer file

$trustedRootCertPfxPath = "${baseCertPath}contoso-signing-root.pfx"
$sslCertPfxPath = "${baseCertPath}contoso-ssl.pfx"  
$gatewayCertPfxPath = $sslCertPfxPath          # Full path to api.contoso.net .pfx file
$portalCertPfxPath = $sslCertPfxPath          # Full path to portal.contoso.net .pfx file
$managementCertPfxPath = $sslCertPfxPath     # Full path to management.contoso.net .pfx file

$gatewayCertPfxPassword = $certPassword          # Password for api.contoso.net pfx certificate
$portalCertPfxPassword = $certPassword        # Password for portal.contoso.net pfx certificate
$managementCertPfxPassword = $certPassword     # Password for management.contoso.net pfx certificate

# These variables may be changed.
$resGroupName = "rg-apim-agw-${deploySuffix}"                                 # Resource group name that will hold all assets
$location = "West Europe"                                         # Azure region that will hold all assets
$apimOrganization = "Contoso"                                 # Organization name    
$appgwName = "agw-contoso-${deploySuffix}"                                    # The name of the Application Gateway


$root = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject "CN=contoso-net-signing-root" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 4096 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign `
    -KeyUsage CertSign -NotAfter (get-date).AddYears(5)

$ssl = New-SelfSignedCertificate -Type Custom -DnsName "*.contoso.net","contoso.net" `
    -KeySpec Signature `
    -Subject "CN=*.contoso.net" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $root

# Export CER of the root and SSL certs
Export-Certificate -Type CERT -Cert $root -FilePath $trustedRootCertCerPath

# Export PFX of the root and SSL certs
$securePassword = ConvertTo-SecureString -String $certPassword -AsPlainText -Force
Export-PfxCertificate -Cert $root -FilePath $trustedRootCertPfxPath  `
    -Password $securePassword
Export-PfxCertificate -Cert $ssl -FilePath $sslCertPfxPath  `
    -ChainOption BuildChain -Password $securePassword

# Export the Root CA certificate from the PFX file on .CER X.509 format
$pfxCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslCertPfxPath, $securePassword)
# Build the certificate chain
$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
$chain.Build($pfxCert)
# Find the root certificate
$rootCert = $chain.ChainElements | Select-Object -Last 1
# Export the root certificate to a CER file
$bytes = $rootCert.Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
[System.IO.File]::WriteAllBytes($trustedRootCertCerPath, $bytes)

# Connect-AzAccount

./secrets.ps1

Get-AzSubscription -Subscriptionid $env:SUBSCRIPTION_ID | Select-AzSubscription


New-AzResourceGroup -Name $resGroupName -Location $location

$appGatewayExternalIP = New-AzPublicIpAddress -ResourceGroupName $resGroupName -name "pip-ag" -location $location -AllocationMethod Static -Sku Standard -Force
$appGatewayInternalIP = "10.0.0.100"

[String[]]$appGwNsgDestIPs = $appGatewayInternalIP, $appGatewayExternalIP.IpAddress

$appGwRule1 = New-AzNetworkSecurityRuleConfig -Name appgw-in -Description "AppGw inbound" -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix GatewayManager -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 65200-65535

$appGwRule2 = New-AzNetworkSecurityRuleConfig -Name appgw-in-internet -Description "AppGw inbound Internet" -Access Allow -Protocol "TCP" -Direction Inbound -Priority 110 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix $appGwNsgDestIPs -DestinationPortRange 443

$appGwNsg = New-AzNetworkSecurityGroup -ResourceGroupName $resGroupName -Location $location -Name "nsg-agw" -SecurityRules $appGwRule1, $appGwRule2

$apimRule1 = New-AzNetworkSecurityRuleConfig -Name APIM-Management -Description "APIM inbound" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix ApiManagement -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3443

$apimRule2 = New-AzNetworkSecurityRuleConfig -Name AllowAppGatewayToAPIM -Description "Allows inbound App Gateway traffic to APIM" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix "10.0.0.0/24" -SourcePortRange * -DestinationAddressPrefix "10.0.1.0/24" -DestinationPortRange 443

$apimRule3 = New-AzNetworkSecurityRuleConfig -Name AllowAzureLoadBalancer -Description "Allows inbound Azure Infrastructure Load Balancer traffic to APIM" -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix AzureLoadBalancer -SourcePortRange * -DestinationAddressPrefix "10.0.1.0/24" -DestinationPortRange 6390

$apimRule4 = New-AzNetworkSecurityRuleConfig -Name AllowKeyVault -Description "Allows outbound traffic to Azure Key Vault" -Access Allow -Protocol Tcp -Direction Outbound -Priority 100 -SourceAddressPrefix "10.0.1.0/24" -SourcePortRange * -DestinationAddressPrefix AzureKeyVault -DestinationPortRange 443

$apimNsg = New-AzNetworkSecurityGroup -ResourceGroupName $resGroupName -Location $location -Name "nsg-apim" -SecurityRules $apimRule1, $apimRule2, $apimRule3, $apimRule4

$appGatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name "appGatewaySubnet" -NetworkSecurityGroup $appGwNsg -AddressPrefix "10.0.0.0/24"

$apimSubnet = New-AzVirtualNetworkSubnetConfig -Name "apimSubnet" -NetworkSecurityGroup $apimNsg -AddressPrefix "10.0.1.0/24"

$vnet = New-AzVirtualNetwork -Name "vnet-contoso" -ResourceGroupName $resGroupName -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $appGatewaySubnet,$apimSubnet

$appGatewaySubnetData = $vnet.Subnets[0]
$apimSubnetData = $vnet.Subnets[1]

$apimPublicIpAddressId = New-AzPublicIpAddress -ResourceGroupName $resGroupName -name "pip-apim" -location $location -AllocationMethod Static -Sku Standard -Force -DomainNameLabel $apimDomainNameLabel

$apimVirtualNetwork = New-AzApiManagementVirtualNetwork -SubnetResourceId $apimSubnetData.Id

$apimService = New-AzApiManagement -ResourceGroupName $resGroupName -Location $location -Name $apimServiceName -Organization $apimOrganization -AdminEmail $apimAdminEmail -VirtualNetwork $apimVirtualNetwork -VpnType "Internal" -Sku "Developer" -PublicIpAddressId $apimPublicIpAddressId.Id

$certGatewayPwd = ConvertTo-SecureString -String $gatewayCertPfxPassword -AsPlainText -Force
$certPortalPwd = ConvertTo-SecureString -String $portalCertPfxPassword -AsPlainText -Force
$certManagementPwd = ConvertTo-SecureString -String $managementCertPfxPassword -AsPlainText -Force

$gatewayHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $gatewayHostname -HostnameType Proxy -PfxPath $gatewayCertPfxPath -PfxPassword $certGatewayPwd

$portalHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $portalHostname -HostnameType DeveloperPortal -PfxPath $portalCertPfxPath -PfxPassword $certPortalPwd

$managementHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $managementHostname -HostnameType Management -PfxPath $managementCertPfxPath -PfxPassword $certManagementPwd

$apimService.ProxyCustomHostnameConfiguration = $gatewayHostnameConfig
$apimService.PortalCustomHostnameConfiguration = $portalHostnameConfig
$apimService.ManagementCustomHostnameConfiguration = $managementHostnameConfig

Set-AzApiManagement -InputObject $apimService

$myZone = New-AzPrivateDnsZone -Name $domain -ResourceGroupName $resGroupName

$link = New-AzPrivateDnsVirtualNetworkLink -ZoneName $domain -ResourceGroupName $resGroupName -Name "mylink" -VirtualNetworkId $vnet.id

$apimIP = $apimService.PrivateIPAddresses[0]

New-AzPrivateDnsRecordSet -Name api -RecordType A -ZoneName $domain -ResourceGroupName $resGroupName -Ttl 3600 -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $apimIP)

New-AzPrivateDnsRecordSet -Name portal -RecordType A -ZoneName $domain -ResourceGroupName $resGroupName -Ttl 3600 -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $apimIP)

New-AzPrivateDnsRecordSet -Name management -RecordType A -ZoneName $domain -ResourceGroupName $resGroupName -Ttl 3600 -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $apimIP)

$gipconfig = New-AzApplicationGatewayIPConfiguration -Name "gatewayIP01" -Subnet $appGatewaySubnetData

$fp01 = New-AzApplicationGatewayFrontendPort -Name "port01"  -Port 443

$fipconfig01 = New-AzApplicationGatewayFrontendIPConfig -Name "gateway-public-ip" -PublicIPAddress $appGatewayExternalIP

$fipconfig02 = New-AzApplicationGatewayFrontendIPConfig -Name "gateway-private-ip" -PrivateIPAddress $appGatewayInternalIP -Subnet $vnet.Subnets[0]

$certGateway = New-AzApplicationGatewaySslCertificate -Name "gatewaycert" -CertificateFile $gatewayCertPfxPath -Password $certGatewayPwd

$certPortal = New-AzApplicationGatewaySslCertificate -Name "portalcert" -CertificateFile $portalCertPfxPath -Password $certPortalPwd

$certManagement = New-AzApplicationGatewaySslCertificate -Name "managementcert" -CertificateFile $managementCertPfxPath -Password $certManagementPwd

# Public/external listeners
$gatewayListener = New-AzApplicationGatewayHttpListener -Name "gatewaylistener" -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $certGateway -HostName $gatewayHostname -RequireServerNameIndication true

$portalListener = New-AzApplicationGatewayHttpListener -Name "portallistener" -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $certPortal -HostName $portalHostname -RequireServerNameIndication true

$managementListener = New-AzApplicationGatewayHttpListener -Name "managementlistener" -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $certManagement -HostName $managementHostname -RequireServerNameIndication true

# Private/internal listeners
$gatewayListenerPrivate = New-AzApplicationGatewayHttpListener -Name "gatewaylistener-private" -Protocol "Https" -FrontendIPConfiguration $fipconfig02 -FrontendPort $fp01 -SslCertificate $certGateway -HostName $gatewayHostname -RequireServerNameIndication true

$portalListenerPrivate = New-AzApplicationGatewayHttpListener -Name "portallistener-private" -Protocol "Https" -FrontendIPConfiguration $fipconfig02 -FrontendPort $fp01 -SslCertificate $certPortal -HostName $portalHostname -RequireServerNameIndication true

$managementListenerPrivate = New-AzApplicationGatewayHttpListener -Name "managementlistener-private" -Protocol "Https" -FrontendIPConfiguration $fipconfig02 -FrontendPort $fp01 -SslCertificate $certManagement -HostName $managementHostname -RequireServerNameIndication true

$apimGatewayProbe = New-AzApplicationGatewayProbeConfig -Name "apimgatewayprobe" -Protocol "Https" -HostName $gatewayHostname -Path "/status-0123456789abcdef" -Interval 30 -Timeout 120 -UnhealthyThreshold 8

$apimPortalProbe = New-AzApplicationGatewayProbeConfig -Name "apimportalprobe" -Protocol "Https" -HostName $portalHostname -Path "/signin" -Interval 60 -Timeout 300 -UnhealthyThreshold 8

$apimManagementProbe = New-AzApplicationGatewayProbeConfig -Name "apimmanagementprobe" -Protocol "Https" -HostName $managementHostname -Path "/ServiceStatus" -Interval 60 -Timeout 300 -UnhealthyThreshold 8

$trustedRootCert = New-AzApplicationGatewayTrustedRootCertificate -Name "allowlistcert1" -CertificateFile $trustedRootCertCerPath

$apimPoolGatewaySetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolGatewaySetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimGatewayProbe -TrustedRootCertificate $trustedRootCert -PickHostNameFromBackendAddress -RequestTimeout 180

# $apimPoolGatewaySetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolGatewaySetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimGatewayProbe -PickHostNameFromBackendAddress -RequestTimeout 180

$apimPoolPortalSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolPortalSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimPortalProbe -TrustedRootCertificate $trustedRootCert -PickHostNameFromBackendAddress -RequestTimeout 180

# $apimPoolPortalSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolPortalSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimPortalProbe  -PickHostNameFromBackendAddress -RequestTimeout 180

$apimPoolManagementSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolManagementSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimManagementProbe -TrustedRootCertificate $trustedRootCert -PickHostNameFromBackendAddress -RequestTimeout 180


# $apimPoolManagementSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolManagementSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimManagementProbe  -PickHostNameFromBackendAddress -RequestTimeout 180

$apimGatewayBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "gatewaybackend" -BackendFqdns $gatewayHostname

$apimPortalBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "portalbackend" -BackendFqdns $portalHostname

$apimManagementBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "managementbackend" -BackendFqdns $managementHostname

# Public/external gateway rules
$gatewayRule = New-AzApplicationGatewayRequestRoutingRule -Name "gatewayrule" -RuleType Basic -HttpListener $gatewayListener -BackendAddressPool $apimGatewayBackendPool -BackendHttpSettings $apimPoolGatewaySetting -Priority 10

$portalRule = New-AzApplicationGatewayRequestRoutingRule -Name "portalrule" -RuleType Basic -HttpListener $portalListener -BackendAddressPool $apimPortalBackendPool -BackendHttpSettings $apimPoolPortalSetting -Priority 20

$managementRule = New-AzApplicationGatewayRequestRoutingRule -Name "managementrule" -RuleType Basic -HttpListener $managementListener -BackendAddressPool $apimManagementBackendPool -BackendHttpSettings $apimPoolManagementSetting -Priority 30

# Private/internal gateway rules
$gatewayRulePrivate = New-AzApplicationGatewayRequestRoutingRule -Name "gatewayrule-private" -RuleType Basic -HttpListener $gatewayListenerPrivate -BackendAddressPool $apimGatewayBackendPool -BackendHttpSettings $apimPoolGatewaySetting -Priority 11

$portalRulePrivate = New-AzApplicationGatewayRequestRoutingRule -Name "portalrule-private" -RuleType Basic -HttpListener $portalListenerPrivate -BackendAddressPool $apimPortalBackendPool -BackendHttpSettings $apimPoolPortalSetting -Priority 21

$managementRulePrivate = New-AzApplicationGatewayRequestRoutingRule -Name "managementrule-private" -RuleType Basic -HttpListener $managementListenerPrivate -BackendAddressPool $apimManagementBackendPool -BackendHttpSettings $apimPoolManagementSetting -Priority 31

$sku = New-AzApplicationGatewaySku -Name "WAF_v2" -Tier "WAF_v2" -Capacity 2

$config = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Prevention"

$policy = New-AzApplicationGatewaySslPolicy -PolicyType Predefined -PolicyName AppGwSslPolicy20220101

$appgw = New-AzApplicationGateway -Name $appgwName -ResourceGroupName $resGroupName -Location $location -Sku $sku -SslPolicy $policy -SslCertificates $certGateway, $certPortal, $certManagement -TrustedRootCertificate $trustedRootCert -BackendAddressPools $apimGatewayBackendPool, $apimPortalBackendPool, $apimManagementBackendPool -BackendHttpSettingsCollection $apimPoolGatewaySetting, $apimPoolPortalSetting, $apimPoolManagementSetting -GatewayIpConfigurations $gipconfig -FrontendIpConfigurations $fipconfig01, $fipconfig02 -FrontendPorts $fp01 -HttpListeners $gatewayListener, $portalListener, $managementListener, $gatewayListenerPrivate, $portalListenerPrivate, $managementListenerPrivate -RequestRoutingRules $gatewayRule, $portalRule, $managementRule, $gatewayRulePrivate, $portalRulePrivate, $managementRulePrivate -Probes $apimGatewayProbe, $apimPortalProbe, $apimManagementProbe -WebApplicationFirewallConfig $config

# $appgw = New-AzApplicationGateway -Name $appgwName -ResourceGroupName $resGroupName -Location $location -Sku $sku -SslPolicy $policy -SslCertificates $certGateway, $certPortal, $certManagement -BackendAddressPools $apimGatewayBackendPool, $apimPortalBackendPool, $apimManagementBackendPool -BackendHttpSettingsCollection $apimPoolGatewaySetting, $apimPoolPortalSetting, $apimPoolManagementSetting -GatewayIpConfigurations $gipconfig -FrontendIpConfigurations $fipconfig01, $fipconfig02 -FrontendPorts $fp01 -HttpListeners $gatewayListener, $portalListener, $managementListener, $gatewayListenerPrivate, $portalListenerPrivate, $managementListenerPrivate -RequestRoutingRules $gatewayRule, $portalRule, $managementRule, $gatewayRulePrivate, $portalRulePrivate, $managementRulePrivate -Probes $apimGatewayProbe, $apimPortalProbe, $apimManagementProbe -WebApplicationFirewallConfig $config


Get-AzApplicationGatewayBackendHealth -Name $appgwName -ResourceGroupName $resGroupName