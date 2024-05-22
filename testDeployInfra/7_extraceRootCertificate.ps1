# Load the PFX file
$pfxPath = "C:\Temp\ApimCertificates\contoso-ssl.pfx"
$pfxPassSecure = ConvertTo-SecureString -String "CertificatePassword98765@@**" -AsPlainText -Force
$pfxCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfxPath, $pfxPassSecure)

# Build the certificate chain
$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
$chain.Build($pfxCert)

# Find the root certificate
$rootCert = $chain.ChainElements | Select-Object -Last 1

# Export the root certificate to a CER file
$bytes = $rootCert.Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
[System.IO.File]::WriteAllBytes("C:\Temp\ApimCertificates\rootca.cer", $bytes)