# Load the certificate
$certPath = "C:\Temp\ApimCertificates\rootca.cer"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)

# Check if the certificate is a root certificate
if ($cert.Subject -eq $cert.Issuer) {
    Write-Output "This is a root certificate."
} else {
    Write-Output "This is not a root certificate."
}

# Check if the certificate is valid
if ($cert.Verify()) {
    Write-Output "The certificate is valid."
} else {
    Write-Output "The certificate is not valid."
}