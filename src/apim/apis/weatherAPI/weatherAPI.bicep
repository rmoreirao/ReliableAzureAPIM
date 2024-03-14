param apimServiceName string
@secure()
param apiKey string

resource apimServiceNameNamedValue 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  name: '${apimServiceName}/WeatherAPI-ApiKey'
  properties: {
    displayName: 'WeatherAPI-ApiKey'
    value: apiKey
    secret: true
  }
}



resource ApimServiceName_weather_data_current_conditions 'Microsoft.ApiManagement/service/apis@2021-01-01-preview' = {
  properties: {
    description: 'Weather Data Current Conditions (Observation On Demand) API provides information on temperature, precipitation, wind, barometric pressure, visibility, ultraviolet (UV) radiation, and other related weather observations elements as well as date/time, weather icon codes and phrases based on geocode and postalKey.\nThe Weather Current Conditions are generated on demand from a system that, at request time, assimilates a variety of meteorological inputs to derive a current condition value precise to the requested location on the Earth\'s surface. The meteorological inputs include physical surface observations, radar, satellite, lightning and short-term forecast models.  The CoD system spatially and temporally blends each input appropriately at request-time, producing a result that improves upon any individual input used on its own.'
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    apiRevision: '1'
    isCurrent: true
    subscriptionRequired: false
    displayName: 'Weather API'
    serviceUrl: 'https://api.weather.com/v3/wx'
    path: 'weather-data-current-conditions'
    protocols: [
      'https'
    ]
  }
  name: '${apimServiceName}/weather-data-current-conditions'
  dependsOn: [
    apimServiceNameNamedValue
  ]
}

resource ApimServiceName_weather_data_current_conditions_65f2e54b5ddd1724c4ff788b 'Microsoft.ApiManagement/service/apis/schemas@2021-01-01-preview' = {
  parent: ApimServiceName_weather_data_current_conditions
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {
      value: '{"InternalServerErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 500 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"500"},"httpMessage":{"type":"string","description":"Http error message","example":"Internal Server Error"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Long error message"}}},"ObservationsCurrentResponse":{"type":"object","description":"This definition is used to describe the observation current response structure","properties":{"cloudCeiling":{"type":"number","description":"Base of lowest Mostly Cloudy or Cloudy layer.  Expressed in feet when units=e or h, and meters when units=m or s. Note- This field can be NULL for any geographic location depending on weather conditions. NULL indicates the ceiling is unlimited (clear skies)."},"cloudCoverPhrase":{"type":"string","description":"Descriptive sky cover - based on percentage of cloud cover. Range - Clear-> coverage < 0.09375; Partly Cloudy-> coverage < .59375; Mostly Cloudy-> coverage < .75; Cloudy-> coverage >= .75"},"dayOfWeek":{"type":"string","description":"Day of week. Range - Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"},"dayOrNight":{"type":"string","description":"Daytime or nighttime of the local apparent time of the location Range - D = Day, N = Night, X = Missing (for extreme northern and southern hemisphere)"},"expirationTimeUtc":{"type":"number","description":"Expiration time in UNIX in UNIX epoch value. This expiration time indicates the data within the response will be outdated."},"iconCode":{"type":"number","description":"This number is the key to the weather icon lookup. The data field shows the icon number that is matched to represent the observed weather conditions.  Icon Code list located here. Range - 0 to 47"},"iconCodeExtend":{"type":"number","description":"A four digit code representing the full set of sensible weather icons.  These codes are companions to iconCode with more specificity."},"obsQualifierCode":{},"obsQualifierSeverity":{},"precip1Hour":{"type":"number","description":"Rolling hour liquid precip amount.  The amounts presented are a rolling time through the request time (now). Units - Expressed in inches when units=e, expressed in millimeters when units=m, s, or h."},"precip6Hour":{"type":"number","description":"Rolling six hour liquid precip amount.  The amounts presented are a rolling time through the request time (now). Units - Expressed in inches when units=e, expressed in millimeters when units=m, s, or h."},"precip24Hour":{"type":"number","description":"Rolling twenty-four hour liquid precip amount.  The amounts presented are a rolling time through the request time (now). Units - Expressed in inches when units=e, expressed in millimeters when units=m, s, or h. Note- Arrival of new, refined data inputs may cause output values to change throughout a given day."},"pressureAltimeter":{"type":"number","description":"Barometric pressure is the pressure exerted by the atmosphere at the Earth’s surface due to the weight of the air. Altitude can be determined based on the measurement of barometric  pressure. The lower the pressure, the greater the altitude. Units - Expressed in inches of mercury when units=e, expressed in millibars when units=m, s, or h. Range - Inches of mercury precise to hundredths; Millibars precise to tenths."},"pressureChange":{"type":"number","description":"Change in pressure in the last three hours. Units - Expressed in inches of mercury for units=e, expressed in millibars when units=m, s, or h."},"pressureMeanSeaLevel":{"type":"number","description":"Mean sea level pressure in millibars.  In other words, the average barometric pressure at sea level. Range - Millibars precise to 1/10th mb"},"pressureTendencyCode":{"type":"number","description":"Code for pressureTendencyTrend. Range - 0 = steady, 1 = rising, 2 = falling, 3 = rapidly rising, 4 = rapidly falling"},"pressureTendencyTrend":{"type":"string","description":"Descriptive text of pressure tendency over the past three hours. Indicates whether pressure is steady, rising, or falling. Range - Steady, Rising, Falling, Rapidly Rising, Rapidly Falling"},"relativeHumidity":{"type":"number","description":"The relative humidity of the air, which is defined as the ratio of the amount of water vapor in the air to the amount of vapor required to bring the air to saturation at a constant temperature. Relative humidity is always expressed as a percentage. Range - 0 to 100"},"snow1Hour":{"type":"number","description":"One hour snowfall amount.  The amounts presented are a rolling time through the request time (now). Units - Expressed in inches when units=e, expressed in centimeters when units=m, s, or h."},"snow6Hour":{"type":"number","description":"Six hour snowfall amount.  The amounts presented are a rolling time through the request time (now). Units - Expressed in inches when units=e, expressed in centimeters when units=m, s, or h."},"snow24Hour":{"type":"number","description":"Twenty four hour snowfall amount.  The amounts presented are a rolling time through the request time (now). Units - Expressed in inches when units=e, expressed in centimeters when units=m, s, or h."},"sunriseTimeLocal":{"type":"string","description":"This field contains the local time of sunrise. It reflects any local daylight savings conventions. NOTE- For a few Arctic and Antarctic regions, the Sunrise and Sunset data values will be null as Sunrise and Sunset do not occur at these locations. Range - ISO 8601 - YYYY-MM-DDTHH:MM:SS-NNNN; NNNN=GMT offset"},"sunriseTimeUtc":{"type":"number","description":"Sunrise time in UNIX epoch value."},"sunsetTimeLocal":{"type":"string","description":"This field contains the local time of the sunset. It reflects any local daylight savings conventions. NOTE- For a few Arctic and Antarctic regions, the Sunrise and Sunset data values will be null as Sunrise and Sunset do not occur at these locations. Range - ISO 8601 - YYYY-MM-DDTHH:MM:SS-NNNN; NNNN=GMT offset."},"sunsetTimeUtc":{"type":"number","description":"Sunset time in UNIX epoch value."},"temperature":{"type":"number","description":"Temperature in defined unit of measure. Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h. Range - -140 to 140"},"temperatureChange24Hour":{"type":"number","description":"Change in temperature compared to the report 24 hours ago. Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h."},"temperatureDewPoint":{"type":"number","description":"The temperature which air must be cooled at constant pressure to reach saturation. The Dew Point is also an indirect measure of the humidity of the air. The Dew Point will never exceed the Temperature. When the Dewpoint and Temperature are equal, clouds or fog will typically form. The closer the values of Temperature and Dew Point, the higher the relative humidity. Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h. Range - -80 to 100 (°F) or -62 to 37 (°C)"},"temperatureFeelsLike":{"type":"number","description":"An apparent temperature. It represents what the air temperature “feels like” on exposed human skin due to the combined effect of the wind chill or heat index. When the temperature is 65°F or higher, the Feels Like value represents the computed Heat Index.  When the temperature is below 65°F, the Feels Like value represents the computed Wind Chill. Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h. Range - -140 to 140"},"temperatureHeatIndex":{"type":"number","description":"An apparent temperature.  It represents what the air temperature “feels like” on exposed human skin due to the combined effect of warm temperatures and high humidity. Below 65°F, it is set = to the temperature. Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h."},"temperatureMax24Hour":{"type":"number","description":"The maximum temperature in the last 24 hours.  The 24 hour period is in reference to the request time (now). Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h."},"temperatureMaxSince7Am":{"type":"number","description":"The maximum temperature since 7 A.M. local time. Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h."},"temperatureMin24Hour":{"type":"number","description":"The minimum temperature in the last 24 hours.  The 24 hour period is in reference to the request time (now). Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h."},"temperatureWindChill":{"type":"number","description":"An apparent temperature. It represents what the air temperature “feels like” on exposed human skin due to the combined effect of the cold temperatures and wind speed. Above 65°F, it is set = to the temperature. Units - Expressed in fahrenheit when units=e, expressed in celsius when units=m, s, or h."},"uvDescription":{"type":"string","description":"The UV Index Description which complements the uvIndex value by providing an associated level of risk of skin damage due to exposure. Range - Not Available, No Report, Low, Moderate, High, Very High, Extreme"},"uvIndex":{"type":"number","description":"TWC’s proprietary UV index.  The UV Index provides indices of the intensity of the solar radiation level and risk of skin damage due to exposure. Range - -2=Not Available, -1=No Report, 0-2=Low, 3-5=Moderate, 6-7=High, 8-10= Very High, 11-16=Extreme"},"validTimeLocal":{"type":"string","description":"Time observation is valid in local. Range - ISO 8601 - YYYY-MM-DDTHH:MM:SS-NNNN; NNNN=GMT offset"},"validTimeUtc":{"type":"number","description":"Time observation is valid in UNIX epoch value."},"visibility":{"type":"number","description":"The horizontal visibility at the observation point. Visibilities can be reported as fractional values particularly when visibility is less than 2 miles. Visibilities greater than 10 statute miles(16.1 kilometers) which are considered “unlimited” are reported as “999” in your feed. You can also find visibility values that equal zero. This occurrence is not wrong. Dense fogs and heavy snows can produce values near zero. Fog, smoke, heavy rain and other weather phenomena can reduce visibility to near zero miles or kilometers. Units - Expressed in miles when units=e, expressed in kilometer when units=m, s, or h. Range - 0 to 999 or null; For greater than 1 = no decimal. For less than 1 = 2 (Metric) & 2 (Imperial) decimal places."},"windDirection":{"type":"number","description":"The magnetic wind direction from which the wind blows expressed in degrees. The magnetic direction varies from 0 to 359 degrees, where 0° indicates the North, 90° the East, 180° the South, 270° the West, and so forth. Range - 0<=wind_dire_deg<=350, in 10 degree intervals"},"windDirectionCardinal":{"type":"string","description":"This field contains the cardinal direction from which the wind blows in an abbreviated form.This field contains the cardinal direction from which the wind blows in an abbreviated form. Wind directions are always expressed as “from whence the wind blows” meaning that a North wind blows from North to South. If you face North in a North wind, the wind is at your face. Face southward and the North wind is at your back. Range - N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW, CALM"},"windGust":{},"windSpeed":{"type":"number","description":"The wind is treated as a vector; hence, winds must have direction and magnitude (speed). The wind information reported in the current conditions corresponds to a 10-minute average called the sustained wind speed. Sudden or brief variations in the wind speed are known as “wind gusts” and are reported in a separate data field. Wind directions are always expressed as \\"from whence the wind blows\\" meaning that a North wind blows from North to South. If you face North in a North wind the wind is at your face. Face southward and the North wind is at your back. Units - Expressed in miles per hour when units=e or h, expressed in kilometers per hour when units=m, expressed in meters per second when units="},"wxPhraseLong":{"type":"string","description":"A text description of observed weather conditions accompanying the iconCode field. Range - 32 character phrase (Character limit applies to English phrases only.  For other languages this phrase may exceed 32 characters)"},"wxPhraseMedium":{"type":"string","description":"A text description of observed weather conditions accompanying the iconCode field. NOTE- This field will be NULL for all languages other than US English (en_US). Range - 22 character phrase"},"wxPhraseShort":{"type":"string","description":"A text description of observed weather conditions accompanying the iconCode field. NOTE- This field will be NULL for all languages other than US English (en_US). Range - 12 character phrase"}},"example":"{\\r\\n\\t\\"cloudCeiling\\": 800,\\r\\n\\t\\"cloudCoverPhrase\\": \\"Partly Cloudy\\",\\r\\n\\t\\"dayOfWeek\\": \\"Monday\\",\\r\\n\\t\\"dayOrNight\\": \\"D\\",\\r\\n\\t\\"expirationTimeUtc\\": 1544455181,\\r\\n\\t\\"iconCode\\": 26,\\r\\n\\t\\"iconCodeExtend\\": 2600,\\r\\n\\t\\"obsQualifierCode\\": null,\\r\\n\\t\\"obsQualifierSeverity\\": null,\\r\\n\\t\\"precip1Hour\\": 0,\\r\\n\\t\\"precip6Hour\\": 0,\\r\\n\\t\\"precip24Hour\\": 0.05,\\r\\n\\t\\"pressureAltimeter\\": 30.14,\\r\\n\\t\\"pressureChange\\": 0.05,\\r\\n\\t\\"pressureMeanSeaLevel\\": 1018.6,\\r\\n\\t\\"pressureTendencyCode\\": 1,\\r\\n\\t\\"pressureTendencyTrend\\": \\"Rising\\",\\r\\n\\t\\"relativeHumidity\\": 95,\\r\\n\\t\\"snow1Hour\\": 0,\\r\\n\\t\\"snow6Hour\\": 0,\\r\\n\\t\\"snow24Hour\\": 0,\\r\\n\\t\\"sunriseTimeLocal\\": \\"2018-12-10T07:34:27-0500\\",\\r\\n\\t\\"sunriseTimeUtc\\": 1544445267,\\r\\n\\t\\"sunsetTimeLocal\\": \\"2018-12-10T17:27:59-0500\\",\\r\\n\\t\\"sunsetTimeUtc\\": 1544480879,\\r\\n\\t\\"temperature\\": 38,\\r\\n\\t\\"temperatureChange24Hour\\": -2,\\r\\n\\t\\"temperatureDewPoint\\": 37,\\r\\n\\t\\"temperatureFeelsLike\\": 38,\\r\\n\\t\\"temperatureHeatIndex\\": 38,\\r\\n\\t\\"temperatureMax24Hour\\": 42,\\r\\n\\t\\"temperatureMaxSince7Am\\": 38,\\r\\n\\t\\"temperatureMin24Hour\\": 36,\\r\\n\\t\\"temperatureWindChill\\": 38,\\r\\n\\t\\"uvDescription\\": \\"Low\\",\\r\\n\\t\\"uvIndex\\": 1,\\r\\n\\t\\"validTimeLocal\\": \\"2018-12-10T10:09:41-0500\\",\\r\\n\\t\\"validTimeUtc\\": 1544454581,\\r\\n\\t\\"visibility\\": 10,\\r\\n\\t\\"windDirection\\": 110,\\r\\n\\t\\"windDirectionCardinal\\": \\"ESE\\",\\r\\n\\t\\"windGust\\": null,\\r\\n\\t\\"windSpeed\\": 2,\\r\\n\\t\\"wxPhraseLong\\": \\"Partly Cloudy\\",\\r\\n\\t\\"wxPhraseMedium\\": \\"Partly Cloudy\\",\\r\\n\\t\\"wxPhraseShort\\": \\"P Cloudy\\"\\r\\n}\\r\\n"},"GenericErrorReponseStructure":{"type":"object","description":"This definition is used to describe the generic error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"HTTP status code (i.e, 404/500 etc..)"},"httpMessage":{"type":"string","description":"Http error message","example":"Short error message"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Long error message"}}},"BadRequestErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 400 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"400"},"httpMessage":{"type":"string","description":"Http error message","example":"Bad Request"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"One or more required API parameters are missing in the API request."}}},"UnauthorizedErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 401 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"401"},"httpMessage":{"type":"string","description":"Http error message","example":"Unauthorized"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Cannot find valid subscription for the incoming API request."}}},"ConnectionErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 503 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"503"},"httpMessage":{"type":"string","description":"Http error message","example":"Connection Error"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Unable to Connect the Target Service"}}},"MethodNotAllowedErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 405 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"405"},"httpMessage":{"type":"string","description":"Http error message","example":"Method Not Allowed"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"The method is not allowed for the requested URL"}}}}'
    }
  }
  name: '65f2e54b5ddd1724c4ff788b'
}

resource ApimServiceName_weather_data_current_conditions_observations_current 'Microsoft.ApiManagement/service/apis/operations@2021-01-01-preview' = {
  parent: ApimServiceName_weather_data_current_conditions
  properties: {
    templateParameters: []
    description: 'This operation is used to get information based on one specific search criteria (either geocode or postalkey) on temperature, precipitation, wind, barometric pressure, visibility, ultraviolet (UV) radiation, and other related weather observations elements as well as date/time, weather icon codes and phrases.'
    request: {
      queryParameters: [
        {
          name: 'geocode'
          description: 'TWC uses valid latitudes and longitude coordinates to identify locations worldwide. for e.g. "latitude , longitude" values (i.e 40.58,-111.66)'
          type: 'string'
          required: false
          values: []
        }
        {
          name: 'postalkey'
          description: 'Postal Key is a composite location identifier key of "Postal Code":"Country Code" for e.g. 81657:US'
          type: 'string'
          required: false
          values: []
        }
        {
          name: 'units'
          description: 'The unit of measure for the response. The following values are supported: e = English units m = Metric units h = Hybrid units (UK) s  = Metric SI units.'
          type: 'string'
          required: false
          values: []
        }
        {
          name: 'language'
          description: 'Language to return the response in (ex. en-US, es, es-MX, fr-FR).'
          type: 'string'
          required: false
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
        headers: []
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n\t"cloudCeiling": 800,\r\n\t"cloudCoverPhrase": "Partly Cloudy",\r\n\t"dayOfWeek": "Monday",\r\n\t"dayOrNight": "D",\r\n\t"expirationTimeUtc": 1544455181,\r\n\t"iconCode": 26,\r\n\t"iconCodeExtend": 2600,\r\n\t"obsQualifierCode": null,\r\n\t"obsQualifierSeverity": null,\r\n\t"precip1Hour": 0,\r\n\t"precip6Hour": 0,\r\n\t"precip24Hour": 0.05,\r\n\t"pressureAltimeter": 30.14,\r\n\t"pressureChange": 0.05,\r\n\t"pressureMeanSeaLevel": 1018.6,\r\n\t"pressureTendencyCode": 1,\r\n\t"pressureTendencyTrend": "Rising",\r\n\t"relativeHumidity": 95,\r\n\t"snow1Hour": 0,\r\n\t"snow6Hour": 0,\r\n\t"snow24Hour": 0,\r\n\t"sunriseTimeLocal": "2018-12-10T07:34:27-0500",\r\n\t"sunriseTimeUtc": 1544445267,\r\n\t"sunsetTimeLocal": "2018-12-10T17:27:59-0500",\r\n\t"sunsetTimeUtc": 1544480879,\r\n\t"temperature": 38,\r\n\t"temperatureChange24Hour": -2,\r\n\t"temperatureDewPoint": 37,\r\n\t"temperatureFeelsLike": 38,\r\n\t"temperatureHeatIndex": 38,\r\n\t"temperatureMax24Hour": 42,\r\n\t"temperatureMaxSince7Am": 38,\r\n\t"temperatureMin24Hour": 36,\r\n\t"temperatureWindChill": 38,\r\n\t"uvDescription": "Low",\r\n\t"uvIndex": 1,\r\n\t"validTimeLocal": "2018-12-10T10:09:41-0500",\r\n\t"validTimeUtc": 1544454581,\r\n\t"visibility": 10,\r\n\t"windDirection": 110,\r\n\t"windDirectionCardinal": "ESE",\r\n\t"windGust": null,\r\n\t"windSpeed": 2,\r\n\t"wxPhraseLong": "Partly Cloudy",\r\n\t"wxPhraseMedium": "Partly Cloudy",\r\n\t"wxPhraseShort": "P Cloudy"\r\n}\r\n'
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'ObservationsCurrentResponse'
          }
        ]
      }
      {
        statusCode: 204
        description: 'No content'
        headers: []
        representations: [
          {
            contentType: 'application/json'
          }
        ]
      }
      {
        statusCode: 400
        description: 'Bad Request'
        headers: []
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n  "httpCode": "400",\r\n  "httpMessage": "Bad Request",\r\n  "moreInformation": "One or more required API parameters are missing in the API request."\r\n}'
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'BadRequestErrorReponseStructure'
          }
        ]
      }
      {
        statusCode: 401
        description: 'Unauthorized'
        headers: []
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n  "httpCode": "401",\r\n  "httpMessage": "Unauthorized",\r\n  "moreInformation": "Cannot find valid subscription for the incoming API request."\r\n}'
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'UnauthorizedErrorReponseStructure'
          }
        ]
      }
      {
        statusCode: 405
        description: 'Method Not Allowed'
        headers: []
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n  "httpCode": "405",\r\n  "httpMessage": "Method Not Allowed",\r\n  "moreInformation": "The method is not allowed for the requested URL"\r\n}'
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'MethodNotAllowedErrorReponseStructure'
          }
        ]
      }
      {
        statusCode: 500
        description: 'Internal server Error'
        headers: []
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n  "httpCode": "500",\r\n  "httpMessage": "Internal Server Error",\r\n  "moreInformation": "Long error message"\r\n}'
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'InternalServerErrorReponseStructure'
          }
        ]
      }
      {
        statusCode: 503
        description: 'Connection Error'
        headers: []
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n  "httpCode": "503",\r\n  "httpMessage": "Connection Error",\r\n  "moreInformation": "Unable to Connect the Target Service"\r\n}'
            schemaId: '65f2e54b5ddd1724c4ff788b'
            typeName: 'ConnectionErrorReponseStructure'
          }
        ]
      }
    ]
    displayName: 'This operation is used to get information based on one specific search criteria (either geocode or postalkey) on temperature, precipitation, wind, barometric pressure, visibility, ultraviolet (UV) radiation, and other related weather observations elements as well as date/time, weather icon codes and'
    method: 'GET'
    urlTemplate: '/observations/current'
  }
  name: 'observations-current'
  dependsOn: [
    ApimServiceName_weather_data_current_conditions_65f2e54b5ddd1724c4ff788b
  ]
}

resource ApimServiceName_weather_data_current_conditions_policy 'Microsoft.ApiManagement/service/apis/policies@2021-01-01-preview' = {
  parent: ApimServiceName_weather_data_current_conditions
  properties: {
    value: loadTextContent('weatherAPIPolicy.xml')
    format: 'xml'
  }
  name: 'policy'
}
