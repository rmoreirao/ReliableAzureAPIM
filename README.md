# ReliableAzureAPIM


## For today:
	
	IaC Pipelines

	API Ops: https://azure.github.io/apiops/

	Diagram and Documentation
		High Level and Low Level

	Both Inbound and Outbound needs to go via Firewall

	Logic Apps - DevOps flow
	
	Log Analytics Workspace - to all resources
	
	Developer Portal Styling

	Functions - test the flow (Deploy to the External Subscription)
		Low prio - but to explain why this is not there
	
## To Access the APIM locally:
	C:\Windows\system32\drivers\etc\hosts

	20.73.209.255 api.rmoreirao.net
	20.73.209.255 devportalold.rmoreirao.net
	20.73.209.255 devportal.rmoreirao.net
	20.73.209.255 management.rmoreirao.net

## Networking questions:
	- VNet and Subnets:
		- Who defines the VNets and Subnets on Prod and Non-Prod subscriptions?
		- Who defines the IP adress ranges for the different environments?

	- How do we connect Out of the Subscriptions?
		- Both for On-prem and Internet?
		- What is the flow for Azure Firewall?
			- What are the requirements for Azure Firewall?

	- How is the Inbound connection to the Subscription working?

	- There are many NSGs and UDRs for the Subnets
		- Are there any guidance / limitations on these?

	- There are Many Private DNS Zones and Private Endpoints - are there any requirements for this? [to list]

	- There are some Public IP Addresses: what are the guidelines for Heineken on Public IP Address on Prod and Non-Prod subscriptions?
		- Ex.: Do we need to protect the inbound flow for Public IP? Do you have guidelines on that?

- Understand the flow for the Azure Firewall?
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

	- **Custom Domain Names**
		- What are the requirements for Custom Domain Names? Check the endpoints
		- Custom Domain names on APIM and App Gateway
 
•	**Where to put the DNS Zones?**
	•	[Not so urgent for now] How do we connect to om-prem / other subscriptions?
	•	What are the requirements for Azure Firewall
 
- Are there naming conventions to be used? Work together on the name of the components
- Decision on which other services to be installed - Azure Functions or Logic Apps – both there to start with

# References

## APIM Landing Zone
	- Add the Github Link here!!!

## App Gateway 
	- [(Use API Management in a virtual network with Azure Application Gateway - Azure API Management | Microsoft Learn)](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway)
	- [Create Serf-service Certificate: Application Gateway with internal API Management and Web App - Code Samples | Microsoft Learn](https://learn.microsoft.com/en-us/samples/azure/azure-quickstart-templates/private-webapp-with-app-gateway-and-apim/)
	- [Sample Bicep: azure-quickstart-templates/quickstarts/microsoft.web/private-webapp-with-app-gateway-and-apim at master · Azure/azure-quickstart-templates (github.com)](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.web/private-webapp-with-app-gateway-and-apim)
	- [Generate self-signed certificate with a custom root CA - Azure Application Gateway | Microsoft Learn](https://learn.microsoft.com/en-us/azure/application-gateway/self-signed-certificates)
	- [Tutorial: Create and configure an application gateway to host multiple web sites using the Azure portal - Azure Application Gateway | Microsoft Learn](https://learn.microsoft.com/en-us/azure/application-gateway/create-multiple-sites-portal)

	- App Gateway + LogAnalytics sample: https://github.com/AzDocs/AzDocs/blob/11872387c6674d1c09b90902195023b965468ab9/src-bicep/Network/applicationGateways.bicep#L8

	- To solve error "The remote server returned an error: (403) Forbidden.'. Please check if the storage account is accessible" - https://stackoverflow.com/questions/69766994/cant-create-a-file-share-in-a-storage-account-while-deploying-logic-app-from-th

	- https://learn.microsoft.com/en-us/answers/questions/1006626/application-gateway-backend-end-pool-not-getting-u

		- stop: az network application-gateway stop -n appgw-rmor2-dev-westeurope-001 -g rg-apim-rmor2-dev-westeurope-001
		- start: az network application-gateway start -n appgw-rmor2-dev-westeurope-001 -g rg-apim-rmor2-dev-westeurope-001

## Stv2 
	- [Azure-Orbital-STAC/deploy/bicep/modules/apim.bicep at 105c1af9c0b5d4749c4c94fa059fdf84b6f2c811 · Azure/Azure-Orbital-STAC (github.com)](https://github.com/Azure/Azure-Orbital-STAC/blob/105c1af9c0b5d4749c4c94fa059fdf84b6f2c811/deploy/bicep/modules/apim.bicep#L67)

	- Have the Public IP set on APIM!

## Firewall
	- https://techcommunity.microsoft.com/t5/azure-paas-blog/api-management-networking-faqs-demystifying-series-ii/ba-p/1502056
	- Look for "Force tunneling": https://learn.microsoft.com/en-us/azure/api-management/api-management-using-with-internal-vnet?tabs=stv2
	- https://github.com/nehalineogi/azure-cross-solution-network-architectures/blob/main/apim/README-firewall.md
	- https://learn.microsoft.com/en-us/azure/app-service/network-secure-outbound-traffic-azure-firewall

	Firewall: [API Management - Networking FAQs (Demystifying Series II) - Microsoft Community Hub](https://techcommunity.microsoft.com/t5/azure-paas-blog/api-management-networking-faqs-demystifying-series-ii/ba-p/1502056#b1)
		https://learn.microsoft.com/en-us/azure/app-service/network-secure-outbound-traffic-azure-firewall
			Subnet address range, accept the default or specify a range that's at least /26 in size.
	- Create UDR like this to route all Internet Traffic to Firewall and Allow APIM to connect internally:

		| Name                  | Address prefix | Next hop type   | Next hop IP address |
		|-----------------------|----------------|-----------------|---------------------|
		| route-apim-to-firewall | 0.0.0.0/0      | VirtualAppliance | 10.2.8.4 (FW private ID)          |
		| fw-apim               | ApiManagement  | Internet        |                     |
		

![alt text](docs/images/urd.png)

## Azure Functions

	- https://learn.microsoft.com/en-us/azure/azure-functions/configure-networking-how-to?tabs=portal
	- https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-vnet
	- Sample Function HTTP trigger: https://github.com/Azure-Samples/functions-vnet-tutorial

## Logic Apps
	- https://www.middleway.eu/deployment-of-standard-logic-app-via-bicep/
	- https://techcommunity.microsoft.com/t5/azure-integration-services-blog/deploying-logic-app-standard-resource-using-bicep-templates-and/ba-p/3760070
	- https://learn.microsoft.com/en-us/azure/logic-apps/single-tenant-overview-compare
	- https://jordanbeandev.com/how-to-deploy-logic-apps-standard-with-bicep-azure-devops/
	- https://learn.microsoft.com/en-us/azure/logic-apps/set-up-devops-deployment-single-tenant-azure-logic-apps?tabs=github

## DevOps
	- https://github.com/mattias-fjellstrom/azure-bicep-upload-data-to-storage/blob/main/main.bicep
	- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/features-windows
	- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
	- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/troubleshoot

# Others

## To publish the Developer Portal:
		1) Go to the Portal via APIM: Developer portal-> Portal overview
		2) Click on "Developer Portal" link on the top of the page
		3) Adjust the url to the App Gateway url
		4) Login and open the Portal
		5) From the Developer Portal, click on "Operations" -> "Publish"
