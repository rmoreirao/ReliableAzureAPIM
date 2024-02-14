# ReliableAzureAPIM

### For today:
	Check the Custom Domains for API Management Portal on the Powershell deployment!!!
	Start with the Firewall configuration
	Functions deploy & test the flow


az deployment sub create --location westeurope --name rmor --template-file main.bicep --parameters workloadName=rmor environment=dev

C:\Windows\system32\drivers\etc\hosts


	Firewall: [API Management - Networking FAQs (Demystifying Series II) - Microsoft Community Hub](https://techcommunity.microsoft.com/t5/azure-paas-blog/api-management-networking-faqs-demystifying-series-ii/ba-p/1502056#b1)
		https://learn.microsoft.com/en-us/azure/app-service/network-secure-outbound-traffic-azure-firewall
			Subnet address range, accept the default or specify a range that's at least /26 in size.

	
To implement:
	Developer Portal via App Gateway [(Use API Management in a virtual network with Azure Application Gateway - Azure API Management | Microsoft Learn)](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway)
		[Create Serf-service Certificate: Application Gateway with internal API Management and Web App - Code Samples | Microsoft Learn](https://learn.microsoft.com/en-us/samples/azure/azure-quickstart-templates/private-webapp-with-app-gateway-and-apim/)
		[Sample Bicep: azure-quickstart-templates/quickstarts/microsoft.web/private-webapp-with-app-gateway-and-apim at master · Azure/azure-quickstart-templates (github.com)](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.web/private-webapp-with-app-gateway-and-apim)
		[Generate self-signed certificate with a custom root CA - Azure Application Gateway | Microsoft Learn](https://learn.microsoft.com/en-us/azure/application-gateway/self-signed-certificates)
		[Tutorial: Create and configure an application gateway to host multiple web sites using the Azure portal - Azure Application Gateway | Microsoft Learn](https://learn.microsoft.com/en-us/azure/application-gateway/create-multiple-sites-portal)
		[Test An API With HTTP Files In VSCode | Tutorial (kenslearningcurve.com)](https://kenslearningcurve.com/tutorials/test-an-api-with-http-files-in-vscode/)

## To publish the Developer Portal:
		1) Go to the Portal via APIM: Developer portal-> Portal overview
		2) Click on "Developer Portal" link on the top of the page
		3) Adjust the url to the App Gateway url
		4) Login and open the Portal
		5) From the Developer Portal, click on "Operations" -> "Publish"
 
Stv2: [Azure-Orbital-STAC/deploy/bicep/modules/apim.bicep at 105c1af9c0b5d4749c4c94fa059fdf84b6f2c811 · Azure/Azure-Orbital-STAC (github.com)](https://github.com/Azure/Azure-Orbital-STAC/blob/105c1af9c0b5d4749c4c94fa059fdf84b6f2c811/deploy/bicep/modules/apim.bicep#L67)



Open Points for Sandbox: 
 
- Access to Azure DevOps project
- Have non-prod Subscription with access to it to test / deploy the solution
- Depends on Networking team to work with us on setting up the Networking components (ex.: IP Address spaces for Subnets)
- What are the Address Spaces for the Subnets?
- **Per Environment:**
		- **Subnets (Private IP ranges)** – Vnet Address Space? is networking team deciding on the Private Networks in our networks?
			- DevOps
			- JumpBox Subnet
			- Bastion Subnet
			- App Gateway Subnet
			- APIM Subnet
			- Private Endpoint Subnet
			- Backend Subnet
			- Azure Firewall
		- **Public Ips** (what are the guidelines for Public Ips?)
			- Bastion
			- APIM
	- **Private DNS Zones** (for sandbox – we do it in our subscriptions – how will it work for the other subscriptions? On the picture the DNS was outside):
		•	azure-api.net - API Gateway
		•	portal.azure-api.net - Developer portal (old)
		•	developer.azure-api.net - The new developer portal
		•	management.azure-api.net -  Management endpoint
		•	scm.azure-api.net - Git (if required – maybe not)
	- **App Gateway**
•	We need to have the certificates for the endpoints
		•	API Gateway
		•	Developer Portal
		•	Certificate is stored in the KeyVault
		•	For the Sandbox, will start with Self-signed certificate – at least for now
 
•	**Where to put the DNS Zones?**
	•	[Not so urgent for now] How do we connect to om-prem / other subscriptions?
	•	What are the requirements for Azure Firewall
 
- Are there naming conventions to be used? Work together on the name of the components
- Decision on which other services to be installed - Azure Functions or Logic Apps – both there to start with
