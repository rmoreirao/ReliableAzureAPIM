@secure()
param subscriptions_65f314b4968e09003f070001_displayName string

@secure()
param subscriptions_65f314b5968e09003f070002_displayName string

@secure()
param users_1_lastName string
param service_apima_hkdi2_dev_westeurope_001_name string = 'apima-hkdi2-dev-westeurope-001'
param virtualNetworks_vnet_apim_hkdi2_dev_westeurope_externalid string = '/subscriptions/2d172aeb-b927-43ec-9808-8c9585119364/resourceGroups/rg-apim-networking-hkdi2-dev-westeurope-001/providers/Microsoft.Network/virtualNetworks/vnet-apim-hkdi2-dev-westeurope'
param publicIPAddresses_pip_apim_hkdi2_dev_westeurope_externalid string = '/subscriptions/2d172aeb-b927-43ec-9808-8c9585119364/resourceGroups/rg-apim-networking-hkdi2-dev-westeurope-001/providers/Microsoft.Network/publicIPAddresses/pip-apim-hkdi2-dev-westeurope'
param components_appi_hkdi2_dev_westeurope_001_externalid string = '/subscriptions/2d172aeb-b927-43ec-9808-8c9585119364/resourceGroups/rg-apim-shared-hkdi2-dev-westeurope-001/providers/Microsoft.Insights/components/appi-hkdi2-dev-westeurope-001'

resource service_apima_hkdi2_dev_westeurope_001_name_resource 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: service_apima_hkdi2_dev_westeurope_001_name
  location: 'West Europe'
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'rmoreirao@microsoft.com'
    publisherName: 'Heineken DI'
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${service_apima_hkdi2_dev_westeurope_001_name}.azure-api.net'
        negotiateClientCertificate: false
        defaultSslBinding: false
        certificateSource: 'BuiltIn'
      }
      {
        type: 'Proxy'
        hostName: 'api.sandbox.heineken-apim.com'
        keyVaultId: 'https://kv-hkdi2-dev-westeurope.vault.azure.net/secrets/sandbox-heineken-apim-com'
        negotiateClientCertificate: false
        certificate: {
          expiry: '2025-03-14T15:37:08+00:00'
          thumbprint: '7E7D76D76D4DBDE248A155831C859A66C8D4D2F1'
          subject: 'CN=sandbox.heineken-apim.com'
        }
        defaultSslBinding: true
        certificateSource: 'KeyVault'
      }
      {
        type: 'DeveloperPortal'
        hostName: 'developer.sandbox.heineken-apim.com'
        keyVaultId: 'https://kv-hkdi2-dev-westeurope.vault.azure.net/secrets/sandbox-heineken-apim-com'
        negotiateClientCertificate: false
        certificate: {
          expiry: '2025-03-14T15:37:08+00:00'
          thumbprint: '7E7D76D76D4DBDE248A155831C859A66C8D4D2F1'
          subject: 'CN=sandbox.heineken-apim.com'
        }
        defaultSslBinding: false
        certificateSource: 'KeyVault'
      }
      {
        type: 'Management'
        hostName: 'management.sandbox.heineken-apim.com'
        keyVaultId: 'https://kv-hkdi2-dev-westeurope.vault.azure.net/secrets/sandbox-heineken-apim-com'
        negotiateClientCertificate: false
        certificate: {
          expiry: '2025-03-14T15:37:08+00:00'
          thumbprint: '7E7D76D76D4DBDE248A155831C859A66C8D4D2F1'
          subject: 'CN=sandbox.heineken-apim.com'
        }
        defaultSslBinding: false
        certificateSource: 'KeyVault'
      }
    ]
    virtualNetworkConfiguration: {
      subnetResourceId: '${virtualNetworks_vnet_apim_hkdi2_dev_westeurope_externalid}/subnets/snet-apim-hkdi2-dev-westeurope-001'
    }
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'False'
    }
    virtualNetworkType: 'Internal'
    natGatewayState: 'Disabled'
    apiVersionConstraint: {}
    publicIpAddressId: publicIPAddresses_pip_apim_hkdi2_dev_westeurope_externalid
    publicNetworkAccess: 'Enabled'
    legacyPortalStatus: 'Disabled'
    developerPortalStatus: 'Enabled'
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'echo-api'
  properties: {
    displayName: 'Echo API'
    apiRevision: '1'
    subscriptionRequired: true
    serviceUrl: 'http://echoapi.cloudapp.net/api'
    path: 'echo'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_holidays_api 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'holidays-api'
  properties: {
    displayName: 'Holidays API'
    apiRevision: '1'
    description: 'This API is used to get the public, local, religious, and other holidays of a particular country through Abstract Holiday API provider.'
    subscriptionRequired: false
    serviceUrl: 'https://holidays.abstractapi.com/v1/'
    path: 'holidays-api'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'weather-data-current-conditions'
  properties: {
    displayName: 'Weather API'
    apiRevision: '1'
    description: 'Weather Data Current Conditions (Observation On Demand) API provides information on temperature, precipitation, wind, barometric pressure, visibility, ultraviolet (UV) radiation, and other related weather observations elements as well as date/time, weather icon codes and phrases based on geocode and postalKey.\nThe Weather Current Conditions are generated on demand from a system that, at request time, assimilates a variety of meteorological inputs to derive a current condition value precise to the requested location on the Earth\'s surface. The meteorological inputs include physical surface observations, radar, satellite, lightning and short-term forecast models.  The CoD system spatially and temporally blends each input appropriately at request-time, producing a result that improves upon any individual input used on its own.'
    subscriptionRequired: false
    serviceUrl: 'https://api.weather.com/v3/wx'
    path: 'weather-data-current-conditions'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_administrators 'Microsoft.ApiManagement/service/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'administrators'
  properties: {
    displayName: 'Administrators'
    description: 'Administrators is a built-in group containing the admin email account provided at the time of service creation. Its membership is managed by the system.'
    type: 'system'
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_developers 'Microsoft.ApiManagement/service/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'developers'
  properties: {
    displayName: 'Developers'
    description: 'Developers is a built-in group. Its membership is managed by the system. Signed-in users fall into this group.'
    type: 'system'
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_guests 'Microsoft.ApiManagement/service/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'guests'
  properties: {
    displayName: 'Guests'
    description: 'Guests is a built-in group. Its membership is managed by the system. Unauthenticated users visiting the developer portal fall into this group.'
    type: 'system'
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_appi_hkdi2_dev_westeurope_001 'Microsoft.ApiManagement/service/loggers@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'appi-hkdi2-dev-westeurope-001'
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: '{{Logger-Credentials--65f318c7217d20180495a64a}}'
    }
    isBuffered: true
    resourceId: components_appi_hkdi2_dev_westeurope_001_externalid
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_65f318c7217d20180495a649 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: '65f318c7217d20180495a649'
  properties: {
    displayName: 'Logger-Credentials--65f318c7217d20180495a64a'
    secret: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_apimService 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'apimServiceName'
  properties: {
    displayName: 'apimServiceName'
    value: 'apima-hkdi2-dev-westeurope-001'
    secret: false
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_developerPortalURL 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'developerPortalURL'
  properties: {
    displayName: 'developerPortalURL'
    value: 'https://developer.sandbox.heineken-apim.com/'
    tags: []
    secret: false
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_HolidayAPI_ApiKey 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'HolidayAPI-ApiKey'
  properties: {
    displayName: 'HolidayAPI-ApiKey'
    secret: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_WeatherAPI_ApiKey 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'WeatherAPI-ApiKey'
  properties: {
    displayName: 'WeatherAPI-ApiKey'
    secret: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_AccountClosedPublisher 'Microsoft.ApiManagement/service/notifications@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'AccountClosedPublisher'
}

resource service_apima_hkdi2_dev_westeurope_001_name_BCC 'Microsoft.ApiManagement/service/notifications@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'BCC'
}

resource service_apima_hkdi2_dev_westeurope_001_name_NewApplicationNotificationMessage 'Microsoft.ApiManagement/service/notifications@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'NewApplicationNotificationMessage'
}

resource service_apima_hkdi2_dev_westeurope_001_name_NewIssuePublisherNotificationMessage 'Microsoft.ApiManagement/service/notifications@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'NewIssuePublisherNotificationMessage'
}

resource service_apima_hkdi2_dev_westeurope_001_name_PurchasePublisherNotificationMessage 'Microsoft.ApiManagement/service/notifications@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'PurchasePublisherNotificationMessage'
}

resource service_apima_hkdi2_dev_westeurope_001_name_QuotaLimitApproachingPublisherNotificationMessage 'Microsoft.ApiManagement/service/notifications@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'QuotaLimitApproachingPublisherNotificationMessage'
}

resource service_apima_hkdi2_dev_westeurope_001_name_RequestPublisherNotificationMessage 'Microsoft.ApiManagement/service/notifications@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'RequestPublisherNotificationMessage'
}

resource service_apima_hkdi2_dev_westeurope_001_name_policy 'Microsoft.ApiManagement/service/policies@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <cors allow-credentials="true">\r\n      <allowed-origins>\r\n        <origin>{{developerPortalURL}}</origin>\r\n        <origin>https://{{apimServiceName}}.developer.azure-api.net</origin>\r\n      </allowed-origins>\r\n      <allowed-methods preflight-result-max-age="300">\r\n        <method>*</method>\r\n      </allowed-methods>\r\n      <allowed-headers>\r\n        <header>*</header>\r\n      </allowed-headers>\r\n      <expose-headers>\r\n        <header>*</header>\r\n      </expose-headers>\r\n    </cors>\r\n  </inbound>\r\n  <backend>\r\n    <forward-request />\r\n  </backend>\r\n  <outbound />\r\n  <on-error />\r\n</policies>'
    format: 'xml'
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_default 'Microsoft.ApiManagement/service/portalconfigs@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'default'
  properties: {
    enableBasicAuth: true
    signin: {
      require: false
    }
    signup: {
      termsOfService: {
        requireConsent: false
      }
    }
    delegation: {
      delegateRegistration: false
      delegateSubscription: false
    }
    cors: {
      allowedOrigins: []
    }
    csp: {
      mode: 'disabled'
      reportUri: []
      allowedSources: []
    }
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_20240315080108 'Microsoft.ApiManagement/service/portalRevisions@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: '20240315080108'
  properties: {
    description: 'Migration 20240315080108.'
    isCurrent: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_delegation 'Microsoft.ApiManagement/service/portalsettings@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'delegation'
  properties: {
    subscriptions: {
      enabled: false
    }
    userRegistration: {
      enabled: false
    }
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_signin 'Microsoft.ApiManagement/service/portalsettings@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'signin'
  properties: {
    enabled: false
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_signup 'Microsoft.ApiManagement/service/portalsettings@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'signup'
  properties: {
    enabled: true
    termsOfService: {
      enabled: false
      consentRequired: false
    }
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'starter'
  properties: {
    displayName: 'Starter'
    description: 'Subscribers will be able to run 5 calls/minute up to a maximum of 100 calls/week.'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'unlimited'
  properties: {
    displayName: 'Unlimited'
    description: 'Subscribers have completely unlimited access to the API. Administrator approval is required.'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource Microsoft_ApiManagement_service_properties_service_apima_hkdi2_dev_westeurope_001_name_65f318c7217d20180495a649 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: '65f318c7217d20180495a649'
  properties: {
    displayName: 'Logger-Credentials--65f318c7217d20180495a64a'
    value: '79c96140-cec3-4a93-bf2e-23ff20611fc1'
    secret: true
  }
}

resource Microsoft_ApiManagement_service_properties_service_apima_hkdi2_dev_westeurope_001_name_apimService 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'apimServiceName'
  properties: {
    displayName: 'apimServiceName'
    value: 'apima-hkdi2-dev-westeurope-001'
    secret: false
  }
}

resource Microsoft_ApiManagement_service_properties_service_apima_hkdi2_dev_westeurope_001_name_developerPortalURL 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'developerPortalURL'
  properties: {
    displayName: 'developerPortalURL'
    value: 'https://developer.sandbox.heineken-apim.com/'
    tags: []
    secret: false
  }
}

resource Microsoft_ApiManagement_service_properties_service_apima_hkdi2_dev_westeurope_001_name_HolidayAPI_ApiKey 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'HolidayAPI-ApiKey'
  properties: {
    displayName: 'HolidayAPI-ApiKey'
    value: '35ee36b1f7074291b952e0171e4c2fd6'
    secret: true
  }
}

resource Microsoft_ApiManagement_service_properties_service_apima_hkdi2_dev_westeurope_001_name_WeatherAPI_ApiKey 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'WeatherAPI-ApiKey'
  properties: {
    displayName: 'WeatherAPI-ApiKey'
    value: 'b7c916f23d824cc38916f23d82fcc397'
    secret: true
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_master 'Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'master'
  properties: {
    scope: '${service_apima_hkdi2_dev_westeurope_001_name_resource.id}/'
    displayName: 'Built-in all-access subscription'
    state: 'active'
    allowTracing: false
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_AccountClosedDeveloper 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'AccountClosedDeveloper'
  properties: {
    subject: 'Thank you for using the $OrganizationName API!'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          On behalf of $OrganizationName and our customers we thank you for giving us a try. Your $OrganizationName API account is now closed.\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Your $OrganizationName Team</p>\r\n    <a href="$DevPortalUrl">$DevPortalUrl</a>\r\n    <p />\r\n  </body>\r\n</html>'
    title: 'Developer farewell letter'
    description: 'Developers receive this farewell email after they close their account.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_ApplicationApprovedNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'ApplicationApprovedNotificationMessage'
  properties: {
    subject: 'Your application $AppName is published in the application gallery'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          We are happy to let you know that your request to publish the $AppName application in the application gallery has been approved. Your application has been published and can be viewed <a href="http://$DevPortalUrl/Applications/Details/$AppId">here</a>.\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Best,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">The $OrganizationName API Team</p>\r\n  </body>\r\n</html>'
    title: 'Application gallery submission approved (deprecated)'
    description: 'Developers who submitted their application for publication in the application gallery on the developer portal receive this email after their submission is approved.'
    parameters: [
      {
        name: 'AppId'
        title: 'Application id'
      }
      {
        name: 'AppName'
        title: 'Application name'
      }
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_ConfirmSignUpIdentityDefault 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'ConfirmSignUpIdentityDefault'
  properties: {
    subject: 'Please confirm your new $OrganizationName API account'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head>\r\n    <meta charset="UTF-8" />\r\n    <title>Letter</title>\r\n  </head>\r\n  <body>\r\n    <table width="100%">\r\n      <tr>\r\n        <td>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'"></p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you for joining the $OrganizationName API program! We host a growing number of cool APIs and strive to provide an awesome experience for API developers.</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">First order of business is to activate your account and get you going. To that end, please click on the following link:</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            <a id="confirmUrl" href="$ConfirmUrl" style="text-decoration:none">\r\n              <strong>$ConfirmUrl</strong>\r\n            </a>\r\n          </p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">If clicking the link does not work, please copy-and-paste or re-type it into your browser\'s address bar and hit "Enter".</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">$OrganizationName API Team</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            <a href="$DevPortalUrl">$DevPortalUrl</a>\r\n          </p>\r\n        </td>\r\n      </tr>\r\n    </table>\r\n  </body>\r\n</html>'
    title: 'New developer account confirmation'
    description: 'Developers receive this email to confirm their e-mail address after they sign up for a new account.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
      {
        name: 'ConfirmUrl'
        title: 'Developer activation URL'
      }
      {
        name: 'DevPortalHost'
        title: 'Developer portal hostname'
      }
      {
        name: 'ConfirmQuery'
        title: 'Query string part of the activation URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_EmailChangeIdentityDefault 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'EmailChangeIdentityDefault'
  properties: {
    subject: 'Please confirm the new email associated with your $OrganizationName API account'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head>\r\n    <meta charset="UTF-8" />\r\n    <title>Letter</title>\r\n  </head>\r\n  <body>\r\n    <table width="100%">\r\n      <tr>\r\n        <td>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'"></p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">You are receiving this email because you made a change to the email address on your $OrganizationName API account.</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Please click on the following link to confirm the change:</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            <a id="confirmUrl" href="$ConfirmUrl" style="text-decoration:none">\r\n              <strong>$ConfirmUrl</strong>\r\n            </a>\r\n          </p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">If clicking the link does not work, please copy-and-paste or re-type it into your browser\'s address bar and hit "Enter".</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">$OrganizationName API Team</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            <a href="$DevPortalUrl">$DevPortalUrl</a>\r\n          </p>\r\n        </td>\r\n      </tr>\r\n    </table>\r\n  </body>\r\n</html>'
    title: 'Email change confirmation'
    description: 'Developers receive this email to confirm a new e-mail address after they change their existing one associated with their account.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
      {
        name: 'ConfirmUrl'
        title: 'Developer confirmation URL'
      }
      {
        name: 'DevPortalHost'
        title: 'Developer portal hostname'
      }
      {
        name: 'ConfirmQuery'
        title: 'Query string part of the confirmation URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_InviteUserNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'InviteUserNotificationMessage'
  properties: {
    subject: 'You are invited to join the $OrganizationName developer network'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          Your account has been created. Please follow the link below to visit the $OrganizationName developer portal and claim it:\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n      <a href="$ConfirmUrl">$ConfirmUrl</a>\r\n    </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Best,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">The $OrganizationName API Team</p>\r\n  </body>\r\n</html>'
    title: 'Invite user'
    description: 'An e-mail invitation to create an account, sent on request by API publishers.'
    parameters: [
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'ConfirmUrl'
        title: 'Confirmation link'
      }
      {
        name: 'DevPortalHost'
        title: 'Developer portal hostname'
      }
      {
        name: 'ConfirmQuery'
        title: 'Query string part of the confirmation link'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_NewCommentNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'NewCommentNotificationMessage'
  properties: {
    subject: '$IssueName issue has a new comment'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">This is a brief note to let you know that $CommenterFirstName $CommenterLastName made the following comment on the issue $IssueName you created:</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">$CommentText</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          To view the issue on the developer portal click <a href="http://$DevPortalUrl/issues/$IssueId">here</a>.\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Best,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">The $OrganizationName API Team</p>\r\n  </body>\r\n</html>'
    title: 'New comment added to an issue (deprecated)'
    description: 'Developers receive this email when someone comments on the issue they created on the Issues page of the developer portal.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'CommenterFirstName'
        title: 'Commenter first name'
      }
      {
        name: 'CommenterLastName'
        title: 'Commenter last name'
      }
      {
        name: 'IssueId'
        title: 'Issue id'
      }
      {
        name: 'IssueName'
        title: 'Issue name'
      }
      {
        name: 'CommentText'
        title: 'Comment text'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_NewDeveloperNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'NewDeveloperNotificationMessage'
  properties: {
    subject: 'Welcome to the $OrganizationName API!'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head>\r\n    <meta charset="UTF-8" />\r\n    <title>Letter</title>\r\n  </head>\r\n  <body>\r\n    <h1 style="color:#000505;font-size:18pt;font-family:\'Segoe UI\'">\r\n          Welcome to <span style="color:#003363">$OrganizationName API!</span></h1>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Your $OrganizationName API program registration is completed and we are thrilled to have you as a customer. Here are a few important bits of information for your reference:</p>\r\n    <table width="100%" style="margin:20px 0">\r\n      <tr>\r\n            #if ($IdentityProvider == "Basic")\r\n            <td width="50%" style="height:40px;vertical-align:top;font-family:\'Segoe UI\';font-size:12pt">\r\n              Please use the following <strong>username</strong> when signing into any of the \${OrganizationName}-hosted developer portals:\r\n            </td><td style="vertical-align:top;font-family:\'Segoe UI\';font-size:12pt"><strong>$DevUsername</strong></td>\r\n            #else\r\n            <td width="50%" style="height:40px;vertical-align:top;font-family:\'Segoe UI\';font-size:12pt">\r\n              Please use the following <strong>$IdentityProvider account</strong> when signing into any of the \${OrganizationName}-hosted developer portals:\r\n            </td><td style="vertical-align:top;font-family:\'Segoe UI\';font-size:12pt"><strong>$DevUsername</strong></td>            \r\n            #end\r\n          </tr>\r\n      <tr>\r\n        <td style="height:40px;vertical-align:top;font-family:\'Segoe UI\';font-size:12pt">\r\n              We will direct all communications to the following <strong>email address</strong>:\r\n            </td>\r\n        <td style="vertical-align:top;font-family:\'Segoe UI\';font-size:12pt">\r\n          <a href="mailto:$DevEmail" style="text-decoration:none">\r\n            <strong>$DevEmail</strong>\r\n          </a>\r\n        </td>\r\n      </tr>\r\n    </table>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Best of luck in your API pursuits!</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">$OrganizationName API Team</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n      <a href="http://$DevPortalUrl">$DevPortalUrl</a>\r\n    </p>\r\n  </body>\r\n</html>'
    title: 'Developer welcome letter'
    description: 'Developers receive this “welcome” email after they confirm their new account.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'DevUsername'
        title: 'Developer user name'
      }
      {
        name: 'DevEmail'
        title: 'Developer email'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
      {
        name: 'IdentityProvider'
        title: 'Identity Provider selected by Organization'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_NewIssueNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'NewIssueNotificationMessage'
  properties: {
    subject: 'Your request $IssueName was received'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you for contacting us. Our API team will review your issue and get back to you soon.</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          Click this <a href="http://$DevPortalUrl/issues/$IssueId">link</a> to view or edit your request.\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Best,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">The $OrganizationName API Team</p>\r\n  </body>\r\n</html>'
    title: 'New issue received (deprecated)'
    description: 'This email is sent to developers after they create a new topic on the Issues page of the developer portal.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'IssueId'
        title: 'Issue id'
      }
      {
        name: 'IssueName'
        title: 'Issue name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_PasswordResetByAdminNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'PasswordResetByAdminNotificationMessage'
  properties: {
    subject: 'Your password was reset'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <table width="100%">\r\n      <tr>\r\n        <td>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'"></p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">The password of your $OrganizationName API account has been reset, per your request.</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n                Your new password is: <strong>$DevPassword</strong></p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Please make sure to change it next time you sign in.</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">$OrganizationName API Team</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            <a href="$DevPortalUrl">$DevPortalUrl</a>\r\n          </p>\r\n        </td>\r\n      </tr>\r\n    </table>\r\n  </body>\r\n</html>'
    title: 'Password reset by publisher notification (Password reset by admin)'
    description: 'Developers receive this email when the publisher resets their password.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'DevPassword'
        title: 'New Developer password'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_PasswordResetIdentityDefault 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'PasswordResetIdentityDefault'
  properties: {
    subject: 'Your password change request'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head>\r\n    <meta charset="UTF-8" />\r\n    <title>Letter</title>\r\n  </head>\r\n  <body>\r\n    <table width="100%">\r\n      <tr>\r\n        <td>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'"></p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">You are receiving this email because you requested to change the password on your $OrganizationName API account.</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Please click on the link below and follow instructions to create your new password:</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            <a id="resetUrl" href="$ConfirmUrl" style="text-decoration:none">\r\n              <strong>$ConfirmUrl</strong>\r\n            </a>\r\n          </p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">If clicking the link does not work, please copy-and-paste or re-type it into your browser\'s address bar and hit "Enter".</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you,</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">$OrganizationName API Team</p>\r\n          <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            <a href="$DevPortalUrl">$DevPortalUrl</a>\r\n          </p>\r\n        </td>\r\n      </tr>\r\n    </table>\r\n  </body>\r\n</html>'
    title: 'Password change confirmation'
    description: 'Developers receive this email when they request a password change of their account. The purpose of the email is to verify that the account owner made the request and to provide a one-time perishable URL for changing the password.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
      {
        name: 'ConfirmUrl'
        title: 'Developer new password instruction URL'
      }
      {
        name: 'DevPortalHost'
        title: 'Developer portal hostname'
      }
      {
        name: 'ConfirmQuery'
        title: 'Query string part of the instruction URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_PurchaseDeveloperNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'PurchaseDeveloperNotificationMessage'
  properties: {
    subject: 'Your subscription to the $ProdName'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Greetings $DevFirstName $DevLastName!</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          Thank you for subscribing to the <a href="http://$DevPortalUrl/products/$ProdId"><strong>$ProdName</strong></a> and welcome to the $OrganizationName developer community. We are delighted to have you as part of the team and are looking forward to the amazing applications you will build using our API!\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Below are a few subscription details for your reference:</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n      <ul>\r\n            #if ($SubStartDate != "")\r\n            <li style="font-size:12pt;font-family:\'Segoe UI\'">Start date: $SubStartDate</li>\r\n            #end\r\n            \r\n            #if ($SubTerm != "")\r\n            <li style="font-size:12pt;font-family:\'Segoe UI\'">Subscription term: $SubTerm</li>\r\n            #end\r\n          </ul>\r\n    </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n            Visit the developer <a href="http://$DevPortalUrl/developer">profile area</a> to manage your subscription and subscription keys\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">A couple of pointers to help get you started:</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n      <strong>\r\n        <a href="http://$DevPortalUrl/docs/services?product=$ProdId">Learn about the API</a>\r\n      </strong>\r\n    </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">The API documentation provides all information necessary to make a request and to process a response. Code samples are provided per API operation in a variety of languages. Moreover, an interactive console allows making API calls directly from the developer portal without writing any code.</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n      <strong>\r\n        <a href="http://$DevPortalUrl/applications">Feature your app in the app gallery</a>\r\n      </strong>\r\n    </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">You can publish your application on our gallery for increased visibility to potential new users.</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n      <strong>\r\n        <a href="http://$DevPortalUrl/issues">Stay in touch</a>\r\n      </strong>\r\n    </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          If you have an issue, a question, a suggestion, a request, or if you just want to tell us something, go to the <a href="http://$DevPortalUrl/issues">Issues</a> page on the developer portal and create a new topic.\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Happy hacking,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">The $OrganizationName API Team</p>\r\n    <a style="font-size:12pt;font-family:\'Segoe UI\'" href="http://$DevPortalUrl">$DevPortalUrl</a>\r\n  </body>\r\n</html>'
    title: 'New subscription activated'
    description: 'Developers receive this acknowledgement email after subscribing to a product.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'ProdId'
        title: 'Product ID'
      }
      {
        name: 'ProdName'
        title: 'Product name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'SubStartDate'
        title: 'Subscription start date'
      }
      {
        name: 'SubTerm'
        title: 'Subscription term'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_QuotaLimitApproachingDeveloperNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'QuotaLimitApproachingDeveloperNotificationMessage'
  properties: {
    subject: 'You are approaching an API quota limit'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head>\r\n    <style>\r\n          body {font-size:12pt; font-family:"Segoe UI","Segoe WP","Tahoma","Arial","sans-serif";}\r\n          .alert { color: red; }\r\n          .child1 { padding-left: 20px; }\r\n          .child2 { padding-left: 40px; }\r\n          .number { text-align: right; }\r\n          .text { text-align: left; }\r\n          th, td { padding: 4px 10px; min-width: 100px; }\r\n          th { background-color: #DDDDDD;}\r\n        </style>\r\n  </head>\r\n  <body>\r\n    <p>Greetings $DevFirstName $DevLastName!</p>\r\n    <p>\r\n          You are approaching the quota limit on you subscription to the <strong>$ProdName</strong> product (primary key $SubPrimaryKey).\r\n          #if ($QuotaResetDate != "")\r\n          This quota will be renewed on $QuotaResetDate.\r\n          #else\r\n          This quota will not be renewed.\r\n          #end\r\n        </p>\r\n    <p>Below are details on quota usage for the subscription:</p>\r\n    <p>\r\n      <table>\r\n        <thead>\r\n          <th class="text">Quota Scope</th>\r\n          <th class="number">Calls</th>\r\n          <th class="number">Call Quota</th>\r\n          <th class="number">Bandwidth</th>\r\n          <th class="number">Bandwidth Quota</th>\r\n        </thead>\r\n        <tbody>\r\n          <tr>\r\n            <td class="text">Subscription</td>\r\n            <td class="number">\r\n                  #if ($CallsAlert == true)\r\n                  <span class="alert">$Calls</span>\r\n                  #else\r\n                  $Calls\r\n                  #end\r\n                </td>\r\n            <td class="number">$CallQuota</td>\r\n            <td class="number">\r\n                  #if ($BandwidthAlert == true)\r\n                  <span class="alert">$Bandwidth</span>\r\n                  #else\r\n                  $Bandwidth\r\n                  #end\r\n                </td>\r\n            <td class="number">$BandwidthQuota</td>\r\n          </tr>\r\n              #foreach ($api in $Apis)\r\n              <tr><td class="child1 text">API: $api.Name</td><td class="number">\r\n                  #if ($api.CallsAlert == true)\r\n                  <span class="alert">$api.Calls</span>\r\n                  #else\r\n                  $api.Calls\r\n                  #end\r\n                </td><td class="number">$api.CallQuota</td><td class="number">\r\n                  #if ($api.BandwidthAlert == true)\r\n                  <span class="alert">$api.Bandwidth</span>\r\n                  #else\r\n                  $api.Bandwidth\r\n                  #end\r\n                </td><td class="number">$api.BandwidthQuota</td></tr>\r\n              #foreach ($operation in $api.Operations)\r\n              <tr><td class="child2 text">Operation: $operation.Name</td><td class="number">\r\n                  #if ($operation.CallsAlert == true)\r\n                  <span class="alert">$operation.Calls</span>\r\n                  #else\r\n                  $operation.Calls\r\n                  #end\r\n                </td><td class="number">$operation.CallQuota</td><td class="number">\r\n                  #if ($operation.BandwidthAlert == true)\r\n                  <span class="alert">$operation.Bandwidth</span>\r\n                  #else\r\n                  $operation.Bandwidth\r\n                  #end\r\n                </td><td class="number">$operation.BandwidthQuota</td></tr>\r\n              #end\r\n              #end\r\n            </tbody>\r\n      </table>\r\n    </p>\r\n    <p>Thank you,</p>\r\n    <p>$OrganizationName API Team</p>\r\n    <a href="$DevPortalUrl">$DevPortalUrl</a>\r\n    <p />\r\n  </body>\r\n</html>'
    title: 'Developer quota limit approaching notification'
    description: 'Developers receive this email to alert them when they are approaching a quota limit.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'ProdName'
        title: 'Product name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'SubPrimaryKey'
        title: 'Primary Subscription key'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
      {
        name: 'QuotaResetDate'
        title: 'Quota reset date'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_RejectDeveloperNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'RejectDeveloperNotificationMessage'
  properties: {
    subject: 'Your subscription request for the $ProdName'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          We would like to inform you that we reviewed your subscription request for the <strong>$ProdName</strong>.\r\n        </p>\r\n        #if ($SubDeclineReason == "")\r\n        <p style="font-size:12pt;font-family:\'Segoe UI\'">Regretfully, we were unable to approve it, as subscriptions are temporarily suspended at this time.</p>\r\n        #else\r\n        <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          Regretfully, we were unable to approve it at this time for the following reason:\r\n          <div style="margin-left: 1.5em;"> $SubDeclineReason </div></p>\r\n        #end\r\n        <p style="font-size:12pt;font-family:\'Segoe UI\'"> We truly appreciate your interest. </p><p style="font-size:12pt;font-family:\'Segoe UI\'">All the best,</p><p style="font-size:12pt;font-family:\'Segoe UI\'">The $OrganizationName API Team</p><a style="font-size:12pt;font-family:\'Segoe UI\'" href="http://$DevPortalUrl">$DevPortalUrl</a></body>\r\n</html>'
    title: 'Subscription request declined'
    description: 'This email is sent to developers when their subscription requests for products requiring publisher approval is declined.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'SubDeclineReason'
        title: 'Reason for declining subscription'
      }
      {
        name: 'ProdName'
        title: 'Product name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_RequestDeveloperNotificationMessage 'Microsoft.ApiManagement/service/templates@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'RequestDeveloperNotificationMessage'
  properties: {
    subject: 'Your subscription request for the $ProdName'
    body: '<!DOCTYPE html >\r\n<html>\r\n  <head />\r\n  <body>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Dear $DevFirstName $DevLastName,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          Thank you for your interest in our <strong>$ProdName</strong> API product!\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">\r\n          We were delighted to receive your subscription request. We will promptly review it and get back to you at <strong>$DevEmail</strong>.\r\n        </p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">Thank you,</p>\r\n    <p style="font-size:12pt;font-family:\'Segoe UI\'">The $OrganizationName API Team</p>\r\n    <a style="font-size:12pt;font-family:\'Segoe UI\'" href="http://$DevPortalUrl">$DevPortalUrl</a>\r\n  </body>\r\n</html>'
    title: 'Subscription request received'
    description: 'This email is sent to developers to acknowledge receipt of their subscription requests for products requiring publisher approval.'
    parameters: [
      {
        name: 'DevFirstName'
        title: 'Developer first name'
      }
      {
        name: 'DevLastName'
        title: 'Developer last name'
      }
      {
        name: 'DevEmail'
        title: 'Developer email'
      }
      {
        name: 'ProdName'
        title: 'Product name'
      }
      {
        name: 'OrganizationName'
        title: 'Organization name'
      }
      {
        name: 'DevPortalUrl'
        title: 'Developer portal URL'
      }
    ]
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_1 'Microsoft.ApiManagement/service/users@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: '1'
  properties: {
    firstName: 'Administrator'
    email: 'rmoreirao@microsoft.com'
    state: 'active'
    identities: [
      {
        provider: 'Azure'
        id: 'rmoreirao@microsoft.com'
      }
    ]
    lastName: users_1_lastName
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_create_resource 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api
  name: 'create-resource'
  properties: {
    displayName: 'Create resource'
    method: 'POST'
    urlTemplate: '/resource'
    templateParameters: []
    description: 'A demonstration of a POST call based on the echo backend above. The request body is expected to contain JSON-formatted data (see example below). A policy is used to automatically transform any request sent in JSON directly to XML. In a real-world scenario this could be used to enable modern clients to speak to a legacy backend.'
    request: {
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          examples: {
            default: {
              value: '{\r\n\t"vehicleType": "train",\r\n\t"maxSpeed": 125,\r\n\t"avgSpeed": 90,\r\n\t"speedUnit": "mph"\r\n}'
            }
          }
        }
      ]
    }
    responses: [
      {
        statusCode: 200
        representations: []
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_holidays_api_get_holidays_country_country_year_year_month_month_day_day 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_holidays_api
  name: 'get-holidays-country-country-year-year-month-month-day-day'
  properties: {
    displayName: 'This operation is used to get holiday details of any country based on their country code and year.'
    method: 'GET'
    urlTemplate: '/?country={country}&year={year}&month={month}&day={day}'
    templateParameters: [
      {
        name: 'country'
        description: '<h4>    The country\'s two letter ISO 3166-1 alpha-2 code.Supported Country</h4><hr/><table>\t<thead>\t\t<tr>\t\t\t<th>Country Code</th>\t\t\t<th>Country Name</th>\t\t</tr>\t</thead>\t<tbody>\t\t<tr><td>AF</td><td>Afghanistan</td></tr>\t\t<tr><td>AL</td><td>Albania</td></tr>\t\t<tr><td>DZ</td><td>Algeria</td></tr>\t\t<tr><td>AS</td><td>American Samoa</td></tr>\t\t<tr><td>AD</td><td>Andorra</td></tr>\t\t<tr><td>AO</td><td>Angola</td></tr>\t\t<tr><td>AI</td><td>Anguilla</td></tr>\t\t<tr><td>AG</td><td>Antigua and Barbuda</td></tr>\t\t<tr><td>AR</td><td>Argentina</td></tr>\t\t<tr><td>AM</td><td>Armenia</td></tr>\t\t<tr><td>AW</td><td>Aruba</td></tr>\t\t<tr><td>AU</td><td>Australia</td></tr>\t\t<tr><td>AT</td><td>Austria</td></tr>\t\t<tr><td>AZ</td><td>Azerbaijan</td></tr>\t\t<tr><td>BH</td><td>Bahrain</td></tr>\t\t<tr><td>BD</td><td>Bangladesh</td></tr>\t\t<tr><td>BB</td><td>Barbados</td></tr>\t\t<tr><td>BY</td><td>Belarus</td></tr>\t\t<tr><td>BE</td><td>Belgium</td></tr>\t\t<tr><td>BZ</td><td>Belize</td></tr>\t\t<tr><td>BJ</td><td>Benin</td></tr>\t\t<tr><td>BM</td><td>Bermuda</td></tr>\t\t<tr><td>BT</td><td>Bhutan</td></tr>\t\t<tr><td>BO</td><td>Bolivia</td></tr>\t\t<tr><td>BA</td><td>Bosnia and Herzegovina</td></tr>\t\t<tr><td>BW</td><td>Botswana</td></tr>\t\t<tr><td>BR</td><td>Brazil</td></tr>\t\t<tr><td>VG</td><td>British Virgin Islands</td></tr>\t\t<tr><td>BN</td><td>Brunei</td></tr>\t\t<tr><td>BG</td><td>Bulgaria</td></tr>\t\t<tr><td>BF</td><td>Burkina Faso</td></tr>\t\t<tr><td>BI</td><td>Burundi</td></tr>\t\t<tr><td>CV</td><td>Cabo Verde</td></tr>\t\t<tr><td>KH</td><td>Cambodia</td></tr>\t\t<tr><td>CM</td><td>Cameroon</td></tr>\t\t<tr><td>CA</td><td>Canada</td></tr>\t\t<tr><td>KY</td><td>Cayman Islands</td></tr>\t\t<tr><td>CF</td><td>Central African Republic</td></tr>\t\t<tr><td>TD</td><td>Chad</td></tr>\t\t<tr><td>CL</td><td>Chile</td></tr>\t\t<tr><td>CN</td><td>China</td></tr>\t\t<tr><td>CO</td><td>Colombia</td></tr>\t\t<tr><td>KM</td><td>Comoros</td></tr>\t\t<tr><td>CG</td><td>Congo</td></tr>\t\t<tr><td>CD</td><td>Congo Democratic Republic</td></tr>\t\t<tr><td>CK</td><td>Cook Islands</td></tr>\t\t<tr><td>CR</td><td>Costa Rica</td></tr>\t\t<tr><td>CI</td><td>Cote d\'Ivoire</td></tr>\t\t<tr><td>HR</td><td>Croatia</td></tr>\t\t<tr><td>CU</td><td>Cuba</td></tr>\t\t<tr><td>CW</td><td>Curaçao</td></tr>\t\t<tr><td>CY</td><td>Cyprus</td></tr>\t\t<tr><td>CZ</td><td>Czechia</td></tr>\t\t<tr><td>DK</td><td>Denmark</td></tr>\t\t<tr><td>DJ</td><td>Djibouti</td></tr>\t\t<tr><td>DM</td><td>Dominica</td></tr>\t\t<tr><td>DO</td><td>Dominican Republic</td></tr>\t\t<tr><td>TL</td><td>East Timor</td></tr>\t\t<tr><td>EC</td><td>Ecuador</td></tr>\t\t<tr><td>EG</td><td>Egypt</td></tr>\t\t<tr><td>SV</td><td>El Salvador</td></tr>\t\t<tr><td>GQ</td><td>Equatorial Guinea</td></tr>\t\t<tr><td>ER</td><td>Eritrea</td></tr>\t\t<tr><td>EE</td><td>Estonia</td></tr>\t\t<tr><td>SZ</td><td>eSwatini</td></tr>\t\t<tr><td>ET</td><td>Ethiopia</td></tr>\t\t<tr><td>FK</td><td>Falkland Islands</td></tr>\t\t<tr><td>FO</td><td>Faroe Islands</td></tr>\t\t<tr><td>FJ</td><td>Fiji</td></tr>\t\t<tr><td>FI</td><td>Finland</td></tr>\t\t<tr><td>FR</td><td>France</td></tr>\t\t<tr><td>GF</td><td>French Guiana</td></tr>\t\t<tr><td>PF</td><td>French Polynesia</td></tr>\t\t<tr><td>GA</td><td>Gabon</td></tr>\t\t<tr><td>GM</td><td>Gambia</td></tr>\t\t<tr><td>GE</td><td>Georgia</td></tr>\t\t<tr><td>DE</td><td>Germany</td></tr>\t\t<tr><td>GH</td><td>Ghana</td></tr>\t\t<tr><td>GI</td><td>Gibraltar</td></tr>\t\t<tr><td>GR</td><td>Greece</td></tr>\t\t<tr><td>GL</td><td>Greenland</td></tr>\t\t<tr><td>GD</td><td>Grenada</td></tr>\t\t<tr><td>GP</td><td>Guadeloupe</td></tr>\t\t<tr><td>GU</td><td>Guam</td></tr>\t\t<tr><td>GT</td><td>Guatemala</td></tr>\t\t<tr><td>GG</td><td>Guernsey</td></tr>\t\t<tr><td>GN</td><td>Guinea</td></tr>\t\t<tr><td>GW</td><td>Guinea-Bissau</td></tr>\t\t<tr><td>GY</td><td>Guyana</td></tr>\t\t<tr><td>HT</td><td>Haiti</td></tr>\t\t<tr><td>HN</td><td>Honduras</td></tr>\t\t<tr><td>HK</td><td>Hong Kong</td></tr>\t\t<tr><td>HU</td><td>Hungary</td></tr>\t\t<tr><td>IS</td><td>Iceland</td></tr>\t\t<tr><td>IN</td><td>India</td></tr>\t\t<tr><td>ID</td><td>Indonesia</td></tr>\t\t<tr><td>IR</td><td>Iran</td></tr>\t\t<tr><td>IQ</td><td>Iraq</td></tr>\t\t<tr><td>IE</td><td>Ireland</td></tr>\t\t<tr><td>IM</td><td>Isle of Man</td></tr>\t\t<tr><td>IL</td><td>Israel</td></tr>\t\t<tr><td>IT</td><td>Italy</td></tr>\t\t<tr><td>JM</td><td>Jamaica</td></tr>\t\t<tr><td>JP</td><td>Japan</td></tr>\t\t<tr><td>JE</td><td>Jersey</td></tr>\t\t<tr><td>JO</td><td>Jordan</td></tr>\t\t<tr><td>KZ</td><td>Kazakhstan</td></tr>\t\t<tr><td>KE</td><td>Kenya</td></tr>\t\t<tr><td>KI</td><td>Kiribati</td></tr>\t\t<tr><td>XK</td><td>Kosovo</td></tr>\t\t<tr><td>KW</td><td>Kuwait</td></tr>\t\t<tr><td>KG</td><td>Kyrgyzstan</td></tr>\t\t<tr><td>LA</td><td>Laos</td></tr>\t\t<tr><td>LV</td><td>Latvia</td></tr>\t\t<tr><td>LB</td><td>Lebanon</td></tr>\t\t<tr><td>LS</td><td>Lesotho</td></tr>\t\t<tr><td>LR</td><td>Liberia</td></tr>\t\t<tr><td>LY</td><td>Libya</td></tr>\t\t<tr><td>LI</td><td>Liechtenstein</td></tr>\t\t<tr><td>LT</td><td>Lithuania</td></tr>\t\t<tr><td>LU</td><td>Luxembourg</td></tr>\t\t<tr><td>MO</td><td>Macau</td></tr>\t\t<tr><td>MG</td><td>Madagascar</td></tr>\t\t<tr><td>MW</td><td>Malawi</td></tr>\t\t<tr><td>MY</td><td>Malaysia</td></tr>\t\t<tr><td>MV</td><td>Maldives</td></tr>\t\t<tr><td>ML</td><td>Mali</td></tr>\t\t<tr><td>MT</td><td>Malta</td></tr>\t\t<tr><td>MH</td><td>Marshall Islands</td></tr>\t\t<tr><td>MQ</td><td>Martinique</td></tr>\t\t<tr><td>MR</td><td>Mauritania</td></tr>\t\t<tr><td>MU</td><td>Mauritius</td></tr>\t\t<tr><td>YT</td><td>Mayotte</td></tr>\t\t<tr><td>MX</td><td>Mexico</td></tr>\t\t<tr><td>FM</td><td>Micronesia</td></tr>\t\t<tr><td>MD</td><td>Moldova</td></tr>\t\t<tr><td>MC</td><td>Monaco</td></tr>\t\t<tr><td>MN</td><td>Mongolia</td></tr>\t\t<tr><td>ME</td><td>Montenegro</td></tr>\t\t<tr><td>MS</td><td>Montserrat</td></tr>\t\t<tr><td>MA</td><td>Morocco</td></tr>\t\t<tr><td>MZ</td><td>Mozambique</td></tr>\t\t<tr><td>MM</td><td>Myanmar</td></tr>\t\t<tr><td>NA</td><td>Namibia</td></tr>\t\t<tr><td>NR</td><td>Nauru</td></tr>\t\t<tr><td>NP</td><td>Nepal</td></tr>\t\t<tr><td>NL</td><td>Netherlands</td></tr>\t\t<tr><td>NC</td><td>New Caledonia</td></tr>\t\t<tr><td>NZ</td><td>New Zealand</td></tr>\t\t<tr><td>NI</td><td>Nicaragua</td></tr>\t\t<tr><td>NE</td><td>Niger</td></tr>\t\t<tr><td>NG</td><td>Nigeria</td></tr>\t\t<tr><td>KP</td><td>North Korea</td></tr>\t\t<tr><td>MK</td><td>North Macedonia</td></tr>\t\t<tr><td>MP</td><td>Northern Mariana Islands</td></tr>\t\t<tr><td>NO</td><td>Norway</td></tr>\t\t<tr><td>OM</td><td>Oman</td></tr>\t\t<tr><td>PK</td><td>Pakistan</td></tr>\t\t<tr><td>PW</td><td>Palau</td></tr>\t\t<tr><td>PA</td><td>Panama</td></tr>\t\t<tr><td>PG</td><td>Papua New Guinea</td></tr>\t\t<tr><td>PY</td><td>Paraguay</td></tr>\t\t<tr><td>PE</td><td>Peru</td></tr>\t\t<tr><td>PH</td><td>Philippines</td></tr>\t\t<tr><td>PL</td><td>Poland</td></tr>\t\t<tr><td>PT</td><td>Portugal</td></tr>\t\t<tr><td>PR</td><td>Puerto Rico</td></tr>\t\t<tr><td>QA</td><td>Qatar</td></tr>\t\t<tr><td>RE</td><td>Reunion</td></tr>\t\t<tr><td>RO</td><td>Romania</td></tr>\t\t<tr><td>RE</td><td>Russia</td></tr>\t\t<tr><td>RW</td><td>Rwanda</td></tr>\t\t<tr><td>SH</td><td>Saint Helena</td></tr>\t\t<tr><td>KN</td><td>Saint Kitts and Nevis</td></tr>\t\t<tr><td>LC</td><td>Saint Lucia</td></tr>\t\t<tr><td>MF</td><td>Saint Martin</td></tr>\t\t<tr><td>PM</td><td>Saint Pierre and Miquelon</td></tr>\t\t<tr><td>VC</td><td>Saint Vincent and the Grenadines</td></tr>\t\t<tr><td>WS</td><td>Samoa</td></tr>\t\t<tr><td>SM</td><td>San Marino</td></tr>\t\t<tr><td>ST</td><td>Sao Tome and Principe</td></tr>\t\t<tr><td>SA</td><td>Saudi Arabia</td></tr>\t\t<tr><td>SN</td><td>Senegal</td></tr>\t\t<tr><td>RS</td><td>Serbia</td></tr>\t\t<tr><td>SC</td><td>Seychelles</td></tr>\t\t<tr><td>SL</td><td>Sierra Leone</td></tr>\t\t<tr><td>SG</td><td>Singapore</td></tr>\t\t<tr><td>SX</td><td>Sint Maarten</td></tr>\t\t<tr><td>SK</td><td>Slovakia</td></tr>\t\t<tr><td>SI</td><td>Slovenia</td></tr>\t\t<tr><td>SB</td><td>Solomon Islands</td></tr>\t\t<tr><td>SO</td><td>Somalia</td></tr>\t\t<tr><td>ZA</td><td>South Africa</td></tr>\t\t<tr><td>KR</td><td>South Korea</td></tr>\t\t<tr><td>SS</td><td>South Sudan</td></tr>\t\t<tr><td>ES</td><td>Spain</td></tr>\t\t<tr><td>LK</td><td>Sri Lanka</td></tr>\t\t<tr><td>BL</td><td>St. Barts</td></tr>\t\t<tr><td>SD</td><td>Sudan</td></tr>\t\t<tr><td>SR</td><td>Suriname</td></tr>\t\t<tr><td>SE</td><td>Sweden</td></tr>\t\t<tr><td>CH</td><td>Switzerland</td></tr>\t\t<tr><td>SY</td><td>Syria</td></tr>\t\t<tr><td>TW</td><td>Taiwan</td></tr>\t\t<tr><td>TJ</td><td>Tajikistan</td></tr>\t\t<tr><td>TZ</td><td>Tanzania</td></tr>\t\t<tr><td>TH</td><td>Thailand</td></tr>\t\t<tr><td>BH</td><td>The Bahamas</td></tr>\t\t<tr><td>TG</td><td>Togo</td></tr>\t\t<tr><td>TO</td><td>Tonga</td></tr>\t\t<tr><td>TT</td><td>Trinidad and Tobago</td></tr>\t\t<tr><td>TN</td><td>Tunisia</td></tr>\t\t<tr><td>TR</td><td>Turkey</td></tr>\t\t<tr><td>TM</td><td>Turkmenistan</td></tr>\t\t<tr><td>TC</td><td>Turks and Caicos Islands</td></tr>\t\t<tr><td>TV</td><td>Tuvalu</td></tr>\t\t<tr><td>UG</td><td>Uganda</td></tr>\t\t<tr><td>UA</td><td>Ukraine</td></tr>\t\t<tr><td>AE</td><td>United Arab Emirates</td></tr>\t\t<tr><td>GB</td><td>United Kingdom</td></tr>\t\t<tr><td>US</td><td>United States</td></tr>\t\t<tr><td>UY</td><td>Uruguay</td></tr>\t\t<tr><td>VI</td><td>US Virgin Islands</td></tr>\t\t<tr><td>UZ</td><td>Uzbekistan</td></tr>\t\t<tr><td>VU</td><td>Vanuatu</td></tr>\t\t<tr><td>VA</td><td>Vatican City (Holy See)</td></tr>\t\t<tr><td>VE</td><td>Venezuela</td></tr>\t\t<tr><td>VN</td><td>Vietnam</td></tr>\t\t<tr><td>WF</td><td>Wallis and Futuna</td></tr>\t\t<tr><td>YE</td><td>Yemen</td></tr>\t\t<tr><td>ZM</td><td>Zambia</td></tr>\t\t<tr><td>ZW</td><td>Zimbabwe</td></tr>\t</tbody></table>'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'year'
        description: 'Format - int32. The year to get the holiday(s) from.'
        type: 'integer'
        required: true
        values: []
      }
      {
        name: 'month'
        description: 'Format - int32. The month to get the holiday(s) from, in the format of 1-12 (e.g., 1 is January, 2 is February, etc).'
        type: 'integer'
        required: true
        values: []
      }
      {
        name: 'day'
        description: 'Format - int32. The day to get the holiday(s) from, in the format of 1-31.'
        type: 'integer'
        required: true
        values: []
      }
    ]
    description: 'This operation is used to get holiday details of any country based on their country code and year.'
    responses: [
      {
        statusCode: 200
        description: 'success'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: '[\r\n    {\r\n        "name": "New Year\'s Day",\r\n        "name_local": "",\r\n        "language": "",\r\n        "description": "",\r\n        "country": "US",\r\n        "location": "United States",\r\n        "type": "National",\r\n        "date": "01/01/2020",\r\n        "date_year": "2020",\r\n        "date_month": "01",\r\n        "date_day": "01",\r\n        "week_day": "Wednesday"\r\n    },\r\n    {\r\n        "name": "World Braille Day",\r\n        "name_local": "",\r\n        "language": "",\r\n        "description": "",\r\n        "country": "US",\r\n        "location": "United States",\r\n        "type": "Worldwide",\r\n        "date": "01/04/2020",\r\n        "date_year": "2020",\r\n        "date_month": "01",\r\n        "date_day": "04",\r\n        "week_day": "Saturday"\r\n    },\r\n    {\r\n        "name": "Epiphany",\r\n        "name_local": "",\r\n        "language": "",\r\n        "description": "",\r\n        "country": "US",\r\n        "location": "United States",\r\n        "type": "Christian",\r\n        "date": "01/06/2020",\r\n        "date_year": "2020",\r\n        "date_month": "01",\r\n        "date_day": "06",\r\n        "week_day": "Monday"\r\n    },\r\n    {\r\n        "name": "International Programmers\' Day",\r\n        "name_local": "",\r\n        "language": "",\r\n        "description": "",\r\n        "country": "US",\r\n        "location": "United States",\r\n        "type": "Worldwide",\r\n        "date": "01/07/2020",\r\n        "date_year": "2020",\r\n        "date_month": "01",\r\n        "date_day": "07",\r\n        "week_day": "Tuesday"\r\n    }\r\n\t]'
              }
            }
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'HolidayResponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'Bad Request'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'BadRequestErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 401
        description: 'Unauthorized'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'UnauthorizedErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 405
        description: 'Method Not Allowed'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'MethodNotAllowedErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 500
        description: 'Internal Server Error'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'InternalServerErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 503
        description: 'Connection Error'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'ConnectionErrorReponseStructure'
          }
        ]
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_modify_resource 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api
  name: 'modify-resource'
  properties: {
    displayName: 'Modify Resource'
    method: 'PUT'
    urlTemplate: '/resource'
    templateParameters: []
    description: 'A demonstration of a PUT call handled by the same "echo" backend as above. You can now specify a request body in addition to headers and it will be returned as well.'
    responses: [
      {
        statusCode: 200
        representations: []
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions_observations_current 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions
  name: 'observations-current'
  properties: {
    displayName: 'This operation is used to get information based on one specific search criteria (either geocode or postalkey) on temperature, precipitation, wind, barometric pressure, visibility, ultraviolet (UV) radiation, and other related weather observations elements as well as date/time, weather icon codes and'
    method: 'GET'
    urlTemplate: '/observations/current'
    templateParameters: []
    description: 'This operation is used to get information based on one specific search criteria (either geocode or postalkey) on temperature, precipitation, wind, barometric pressure, visibility, ultraviolet (UV) radiation, and other related weather observations elements as well as date/time, weather icon codes and phrases.'
    request: {
      queryParameters: [
        {
          name: 'geocode'
          description: 'TWC uses valid latitudes and longitude coordinates to identify locations worldwide. for e.g. "latitude , longitude" values (i.e 40.58,-111.66)'
          type: 'string'
          values: []
        }
        {
          name: 'postalkey'
          description: 'Postal Key is a composite location identifier key of "Postal Code":"Country Code" for e.g. 81657:US'
          type: 'string'
          values: []
        }
        {
          name: 'units'
          description: 'The unit of measure for the response. The following values are supported: e = English units m = Metric units h = Hybrid units (UK) s  = Metric SI units.'
          type: 'string'
          values: []
        }
        {
          name: 'language'
          description: 'Language to return the response in (ex. en-US, es, es-MX, fr-FR).'
          type: 'string'
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: [
      {
        statusCode: 200
        description: 'success'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: '{\r\n\t"cloudCeiling": 800,\r\n\t"cloudCoverPhrase": "Partly Cloudy",\r\n\t"dayOfWeek": "Monday",\r\n\t"dayOrNight": "D",\r\n\t"expirationTimeUtc": 1544455181,\r\n\t"iconCode": 26,\r\n\t"iconCodeExtend": 2600,\r\n\t"obsQualifierCode": null,\r\n\t"obsQualifierSeverity": null,\r\n\t"precip1Hour": 0,\r\n\t"precip6Hour": 0,\r\n\t"precip24Hour": 0.05,\r\n\t"pressureAltimeter": 30.14,\r\n\t"pressureChange": 0.05,\r\n\t"pressureMeanSeaLevel": 1018.6,\r\n\t"pressureTendencyCode": 1,\r\n\t"pressureTendencyTrend": "Rising",\r\n\t"relativeHumidity": 95,\r\n\t"snow1Hour": 0,\r\n\t"snow6Hour": 0,\r\n\t"snow24Hour": 0,\r\n\t"sunriseTimeLocal": "2018-12-10T07:34:27-0500",\r\n\t"sunriseTimeUtc": 1544445267,\r\n\t"sunsetTimeLocal": "2018-12-10T17:27:59-0500",\r\n\t"sunsetTimeUtc": 1544480879,\r\n\t"temperature": 38,\r\n\t"temperatureChange24Hour": -2,\r\n\t"temperatureDewPoint": 37,\r\n\t"temperatureFeelsLike": 38,\r\n\t"temperatureHeatIndex": 38,\r\n\t"temperatureMax24Hour": 42,\r\n\t"temperatureMaxSince7Am": 38,\r\n\t"temperatureMin24Hour": 36,\r\n\t"temperatureWindChill": 38,\r\n\t"uvDescription": "Low",\r\n\t"uvIndex": 1,\r\n\t"validTimeLocal": "2018-12-10T10:09:41-0500",\r\n\t"validTimeUtc": 1544454581,\r\n\t"visibility": 10,\r\n\t"windDirection": 110,\r\n\t"windDirectionCardinal": "ESE",\r\n\t"windGust": null,\r\n\t"windSpeed": 2,\r\n\t"wxPhraseLong": "Partly Cloudy",\r\n\t"wxPhraseMedium": "Partly Cloudy",\r\n\t"wxPhraseShort": "P Cloudy"\r\n}\r\n'
              }
            }
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'ObservationsCurrentResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 204
        description: 'No content'
        representations: [
          {
            contentType: 'application/json'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'Bad Request'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'BadRequestErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 401
        description: 'Unauthorized'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'UnauthorizedErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 405
        description: 'Method Not Allowed'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'MethodNotAllowedErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 500
        description: 'Internal server Error'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'InternalServerErrorReponseStructure'
          }
        ]
        headers: []
      }
      {
        statusCode: 503
        description: 'Connection Error'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'ConnectionErrorReponseStructure'
          }
        ]
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_remove_resource 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api
  name: 'remove-resource'
  properties: {
    displayName: 'Remove resource'
    method: 'DELETE'
    urlTemplate: '/resource'
    templateParameters: []
    description: 'A demonstration of a DELETE call which traditionally deletes the resource. It is based on the same "echo" backend as in all other operations so nothing is actually deleted.'
    responses: [
      {
        statusCode: 200
        representations: []
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_retrieve_header_only 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api
  name: 'retrieve-header-only'
  properties: {
    displayName: 'Retrieve header only'
    method: 'HEAD'
    urlTemplate: '/resource'
    templateParameters: []
    description: 'The HEAD operation returns only headers. In this demonstration a policy is used to set additional headers when the response is returned and to enable JSONP.'
    responses: [
      {
        statusCode: 200
        representations: []
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_retrieve_resource 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api
  name: 'retrieve-resource'
  properties: {
    displayName: 'Retrieve resource'
    method: 'GET'
    urlTemplate: '/resource'
    templateParameters: []
    description: 'A demonstration of a GET call on a sample resource. It is handled by an "echo" backend which returns a response equal to the request (the supplied headers and body are being returned as received).'
    request: {
      queryParameters: [
        {
          name: 'param1'
          description: 'A sample parameter that is required and has a default value of "sample".'
          type: 'string'
          defaultValue: 'sample'
          required: true
          values: [
            'sample'
          ]
        }
        {
          name: 'param2'
          description: 'Another sample parameter, set to not required.'
          type: 'number'
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: [
      {
        statusCode: 200
        description: 'Returned in all cases.'
        representations: []
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_retrieve_resource_cached 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api
  name: 'retrieve-resource-cached'
  properties: {
    displayName: 'Retrieve resource (cached)'
    method: 'GET'
    urlTemplate: '/resource-cached'
    templateParameters: []
    description: 'A demonstration of a GET call with caching enabled on the same "echo" backend as above. Cache TTL is set to 1 hour. When you make the first request the headers you supplied will be cached. Subsequent calls will return the same headers as the first time even if you change them in your request.'
    request: {
      queryParameters: [
        {
          name: 'param1'
          description: 'A sample parameter that is required and has a default value of "sample".'
          type: 'string'
          defaultValue: 'sample'
          required: true
          values: [
            'sample'
          ]
        }
        {
          name: 'param2'
          description: 'Another sample parameter, set to not required.'
          type: 'string'
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: [
      {
        statusCode: 200
        representations: []
        headers: []
      }
    ]
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_holidays_api_policy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_holidays_api
  name: 'policy'
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-query-parameter name="api_key" exists-action="override">\r\n      <value>{{HolidayAPI-ApiKey}}</value>\r\n    </set-query-parameter>\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions_policy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions
  name: 'policy'
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-query-parameter name="apiKey" exists-action="override">\r\n      <value>{{WeatherAPI-ApiKey}}</value>\r\n    </set-query-parameter>\r\n    <set-query-parameter name="format" exists-action="override">\r\n      <value>json</value>\r\n    </set-query-parameter>\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_holidays_api_65f2d0c65ddd1724c4ff786f 'Microsoft.ApiManagement/service/apis/schemas@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_holidays_api
  name: '65f2d0c65ddd1724c4ff786f'
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions_65f2e54b5ddd1724c4ff788b 'Microsoft.ApiManagement/service/apis/schemas@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions
  name: '65f2e54b5ddd1724c4ff788b'
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_default 'Microsoft.ApiManagement/service/apis/wikis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api
  name: 'default'
  properties: {
    documents: []
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_holidays_api_default 'Microsoft.ApiManagement/service/apis/wikis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_holidays_api
  name: 'default'
  properties: {
    documents: []
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions_default 'Microsoft.ApiManagement/service/apis/wikis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions
  name: 'default'
  properties: {
    documents: []
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    logClientIp: true
    loggerId: service_apima_hkdi2_dev_westeurope_001_name_appi_hkdi2_dev_westeurope_001.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        dataMasking: {
          queryParams: [
            {
              value: '*'
              mode: 'Hide'
            }
          ]
        }
      }
    }
    backend: {
      request: {
        dataMasking: {
          queryParams: [
            {
              value: '*'
              mode: 'Hide'
            }
          ]
        }
      }
    }
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_applicationinsights_appi_hkdi2_dev_westeurope_001 'Microsoft.ApiManagement/service/diagnostics/loggers@2018-01-01' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_applicationinsights
  name: 'appi-hkdi2-dev-westeurope-001'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_administrators_1 'Microsoft.ApiManagement/service/groups/users@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_administrators
  name: '1'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_developers_1 'Microsoft.ApiManagement/service/groups/users@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_developers
  name: '1'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_echo_api 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'echo-api'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_echo_api 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'echo-api'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_holidays_api 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'holidays-api'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_holidays_api 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'holidays-api'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_weather_data_current_conditions 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'weather-data-current-conditions'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_weather_data_current_conditions 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'weather-data-current-conditions'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_administrators 'Microsoft.ApiManagement/service/products/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'administrators'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_administrators 'Microsoft.ApiManagement/service/products/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'administrators'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_developers 'Microsoft.ApiManagement/service/products/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'developers'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_developers 'Microsoft.ApiManagement/service/products/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'developers'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_guests 'Microsoft.ApiManagement/service/products/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'guests'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_guests 'Microsoft.ApiManagement/service/products/groups@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'guests'
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_policy 'Microsoft.ApiManagement/service/products/policies@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'policy'
  properties: {
    value: '<!--\r\n            IMPORTANT:\r\n            - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n            - Only the <forward-request> policy element can appear within the <backend> section element.\r\n            - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n            - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n            - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.\r\n            - To remove a policy, delete the corresponding policy statement from the policy document.\r\n            - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n            - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n            - Policies are applied in the order of their appearance, from the top down.\r\n        -->\r\n<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_default 'Microsoft.ApiManagement/service/products/wikis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'default'
  properties: {
    documents: []
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_default 'Microsoft.ApiManagement/service/products/wikis@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'default'
  properties: {
    documents: []
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_create_resource_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api_create_resource
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <json-to-xml apply="always" consider-accept-header="false" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_echo_api
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_retrieve_header_only_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api_retrieve_header_only
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n    <set-header name="X-My-Sample" exists-action="override">\r\n      <value>This is a sample</value>\r\n      <!-- for multiple headers with the same name add additional value elements -->\r\n    </set-header>\r\n    <jsonp callback-parameter-name="ProcessResponse" />\r\n  </outbound>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_echo_api
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_echo_api_retrieve_resource_cached_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_echo_api_retrieve_resource_cached
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <cache-lookup vary-by-developer="false" vary-by-developer-groups="false">\r\n      <vary-by-header>Accept</vary-by-header>\r\n      <vary-by-header>Accept-Charset</vary-by-header>\r\n    </cache-lookup>\r\n    <rewrite-uri template="/resource" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n    <cache-store duration="3600" />\r\n  </outbound>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_echo_api
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_0D890F0E_542E_44E9_802F_EC600B87661C 'Microsoft.ApiManagement/service/products/apiLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: '0D890F0E-542E-44E9-802F-EC600B87661C'
  properties: {
    apiId: service_apima_hkdi2_dev_westeurope_001_name_echo_api.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_65f40728217d201130233807 'Microsoft.ApiManagement/service/products/apiLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: '65f40728217d201130233807'
  properties: {
    apiId: service_apima_hkdi2_dev_westeurope_001_name_holidays_api.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_65f40728217d201130233809 'Microsoft.ApiManagement/service/products/apiLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: '65f40728217d201130233809'
  properties: {
    apiId: service_apima_hkdi2_dev_westeurope_001_name_holidays_api.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_65f4072f217d20113023380c 'Microsoft.ApiManagement/service/products/apiLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: '65f4072f217d20113023380c'
  properties: {
    apiId: service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_65f4072f217d20113023380d 'Microsoft.ApiManagement/service/products/apiLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: '65f4072f217d20113023380d'
  properties: {
    apiId: service_apima_hkdi2_dev_westeurope_001_name_weather_data_current_conditions.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_F1FAAEA8_3198_4565_881E_6B9F5AB39CF6 'Microsoft.ApiManagement/service/products/apiLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: 'F1FAAEA8-3198-4565-881E-6B9F5AB39CF6'
  properties: {
    apiId: service_apima_hkdi2_dev_westeurope_001_name_echo_api.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_3EFDCF34_FBDF_4A63_B576_2432026C0856 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: '3EFDCF34-FBDF-4A63-B576-2432026C0856'
  properties: {
    groupId: service_apima_hkdi2_dev_westeurope_001_name_administrators.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_4C4121F8_D109_4D5C_A23D_1967A6EFDCC9 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: '4C4121F8-D109-4D5C-A23D-1967A6EFDCC9'
  properties: {
    groupId: service_apima_hkdi2_dev_westeurope_001_name_guests.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_unlimited_76B4F7CE_D28C_4DCC_9D35_6BEC13B8F6D1 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_unlimited
  name: '76B4F7CE-D28C-4DCC-9D35-6BEC13B8F6D1'
  properties: {
    groupId: service_apima_hkdi2_dev_westeurope_001_name_developers.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_8D82373F_4FA1_456D_BF27_F6A2C097C179 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: '8D82373F-4FA1-456D-BF27-F6A2C097C179'
  properties: {
    groupId: service_apima_hkdi2_dev_westeurope_001_name_administrators.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_A039223C_6DB8_484E_9B75_5EC9C827035B 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'A039223C-6DB8-484E-9B75-5EC9C827035B'
  properties: {
    groupId: service_apima_hkdi2_dev_westeurope_001_name_guests.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_starter_E38B29CD_7F03_4FEF_A184_6EEF7BF62940 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_starter
  name: 'E38B29CD-7F03-4FEF-A184-6EEF7BF62940'
  properties: {
    groupId: service_apima_hkdi2_dev_westeurope_001_name_developers.id
  }
  dependsOn: [
    service_apima_hkdi2_dev_westeurope_001_name_resource
  ]
}

resource service_apima_hkdi2_dev_westeurope_001_name_65f314b4968e09003f070001 'Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: '65f314b4968e09003f070001'
  properties: {
    ownerId: service_apima_hkdi2_dev_westeurope_001_name_1.id
    scope: service_apima_hkdi2_dev_westeurope_001_name_starter.id
    state: 'active'
    allowTracing: false
    displayName: subscriptions_65f314b4968e09003f070001_displayName
  }
}

resource service_apima_hkdi2_dev_westeurope_001_name_65f314b5968e09003f070002 'Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview' = {
  parent: service_apima_hkdi2_dev_westeurope_001_name_resource
  name: '65f314b5968e09003f070002'
  properties: {
    ownerId: service_apima_hkdi2_dev_westeurope_001_name_1.id
    scope: service_apima_hkdi2_dev_westeurope_001_name_unlimited.id
    state: 'active'
    allowTracing: false
    displayName: subscriptions_65f314b5968e09003f070002_displayName
  }
}
