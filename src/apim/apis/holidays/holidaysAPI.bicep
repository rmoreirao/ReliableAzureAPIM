param apimServiceName string
@secure()
param apiKey string

// create Holiday Data product
resource holidaysProduct 'Microsoft.ApiManagement/service/products@2021-01-01-preview' = {
  name: '${apimServiceName}/holidays'
  properties: {
    displayName: 'Holiday Data'
    description: 'Find the dates of public, national and religious holidays for any specific year in more than 200 countries worldwide.'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1000
    state: 'published'
  }
}


resource holidayapiKeyNameValue 'Microsoft.ApiManagement/service/namedValues@2023-05-01-preview' = {
  name: '${apimServiceName}/HolidayAPI-ApiKey'
  properties: {
    displayName: 'HolidayAPI-ApiKey'
    value: apiKey
    secret: true
  }
}

resource holidaysApi 'Microsoft.ApiManagement/service/apis@2021-01-01-preview' = {

  properties: {
    description: 'This API is used to get the public, local, religious, and other holidays of a particular country through Abstract Holiday API provider.'
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    apiRevision: '1'
    isCurrent: true
    subscriptionRequired: false
    displayName: 'Holidays API'
    serviceUrl: 'https://holidays.abstractapi.com/v1/'
    path: 'holidays-api'
    protocols: [
      'https'
    ]
  }
  name: '${apimServiceName}/holidays-api'
  dependsOn: [
    holidayapiKeyNameValue
  ]
}

resource ApimServiceName_holidays_api_65f2d0c65ddd1724c4ff786f 'Microsoft.ApiManagement/service/apis/schemas@2021-01-01-preview' = {
  parent: holidaysApi
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {
      value: '{"HolidayResponseStructure":{"type":"array","description":"This definition is used to describe the create holiday response structure","items":{"type":"object","properties":{"name":{"type":"string","description":"The name of the holiday."},"name_local":{"type":"string","description":"The local name of the holiday."},"language":{"type":"string","description":"If the name_local is used, then this specifies the language in which it is in."},"description":{"type":"string","description":"A short description or additional details on the holiday, such as whether it is part of a long weekend."},"country":{"type":"string","description":"The country in which the holiday occurs, returned directly from the request."},"location":{"type":"string","description":"The location or region in which the holiday occurs, if the holiday is that specific."},"type":{"type":"string","description":"The type of holiday it is (e.g., public holiday, religious holiday, etc)."},"date":{"type":"string","description":"The date on which the holiday occurs."},"date_year":{"type":"string","description":"The year in which the holiday occurs."},"date_month":{"type":"string","description":"The month in which the holiday occurs."},"date_day":{"type":"string","description":"The day in which the holiday occurs."},"week_day":{"type":"string","description":"The day of the week on which the holiday occurs (Monday, Tuesday, Wednesday, etc.)"}}},"example":"[\\r\\n    {\\r\\n        \\"name\\": \\"New Year\'s Day\\",\\r\\n        \\"name_local\\": \\"\\",\\r\\n        \\"language\\": \\"\\",\\r\\n        \\"description\\": \\"\\",\\r\\n        \\"country\\": \\"US\\",\\r\\n        \\"location\\": \\"United States\\",\\r\\n        \\"type\\": \\"National\\",\\r\\n        \\"date\\": \\"01/01/2020\\",\\r\\n        \\"date_year\\": \\"2020\\",\\r\\n        \\"date_month\\": \\"01\\",\\r\\n        \\"date_day\\": \\"01\\",\\r\\n        \\"week_day\\": \\"Wednesday\\"\\r\\n    },\\r\\n    {\\r\\n        \\"name\\": \\"World Braille Day\\",\\r\\n        \\"name_local\\": \\"\\",\\r\\n        \\"language\\": \\"\\",\\r\\n        \\"description\\": \\"\\",\\r\\n        \\"country\\": \\"US\\",\\r\\n        \\"location\\": \\"United States\\",\\r\\n        \\"type\\": \\"Worldwide\\",\\r\\n        \\"date\\": \\"01/04/2020\\",\\r\\n        \\"date_year\\": \\"2020\\",\\r\\n        \\"date_month\\": \\"01\\",\\r\\n        \\"date_day\\": \\"04\\",\\r\\n        \\"week_day\\": \\"Saturday\\"\\r\\n    },\\r\\n    {\\r\\n        \\"name\\": \\"Epiphany\\",\\r\\n        \\"name_local\\": \\"\\",\\r\\n        \\"language\\": \\"\\",\\r\\n        \\"description\\": \\"\\",\\r\\n        \\"country\\": \\"US\\",\\r\\n        \\"location\\": \\"United States\\",\\r\\n        \\"type\\": \\"Christian\\",\\r\\n        \\"date\\": \\"01/06/2020\\",\\r\\n        \\"date_year\\": \\"2020\\",\\r\\n        \\"date_month\\": \\"01\\",\\r\\n        \\"date_day\\": \\"06\\",\\r\\n        \\"week_day\\": \\"Monday\\"\\r\\n    },\\r\\n    {\\r\\n        \\"name\\": \\"International Programmers\' Day\\",\\r\\n        \\"name_local\\": \\"\\",\\r\\n        \\"language\\": \\"\\",\\r\\n        \\"description\\": \\"\\",\\r\\n        \\"country\\": \\"US\\",\\r\\n        \\"location\\": \\"United States\\",\\r\\n        \\"type\\": \\"Worldwide\\",\\r\\n        \\"date\\": \\"01/07/2020\\",\\r\\n        \\"date_year\\": \\"2020\\",\\r\\n        \\"date_month\\": \\"01\\",\\r\\n        \\"date_day\\": \\"07\\",\\r\\n        \\"week_day\\": \\"Tuesday\\"\\r\\n    }\\r\\n\\t]"},"InternalServerErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 500 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"500"},"httpMessage":{"type":"string","description":"Http error message","example":"Internal Server Error"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Long error message"}}},"ConnectionErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 503 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"503"},"httpMessage":{"type":"string","description":"Http error message","example":"Connection Error"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Unable to Connect the Target Service"}}},"GenericErrorReponseStructure":{"type":"object","description":"This definition is used to describe the generic error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"HTTP status code (i.e, 400/401/503/405)"},"httpMessage":{"type":"string","description":"Http error message","example":"Short error message"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Long error message"}}},"BadRequestErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 400 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"400"},"httpMessage":{"type":"string","description":"Http error message","example":"Bad Request"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"One or more required API parameters are missing in the API request."}}},"UnauthorizedErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 401 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"401"},"httpMessage":{"type":"string","description":"Http error message","example":"Unauthorized"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"Cannot find valid subscription for the incoming API request."}}},"MethodNotAllowedErrorReponseStructure":{"type":"object","description":"This definition is used to describe the 405 error response structure.","additionalProperties":false,"properties":{"httpCode":{"type":"string","description":"Http error code","example":"405"},"httpMessage":{"type":"string","description":"Http error message","example":"Method Not Allowed"},"moreInformation":{"type":"string","description":"Additional information on http error message","example":"The method is not allowed for the requested URL"}}},"Year":{"format":"int32","x-apim-inline":true},"Month":{"format":"int32","x-apim-inline":true},"Day":{"format":"int32","x-apim-inline":true}}'
    }
  }
  name: '65f2d0c65ddd1724c4ff786f'
}

resource ApimServiceName_holidays_api_get_holidays_country_country_year_year_month_month_day_day 'Microsoft.ApiManagement/service/apis/operations@2021-01-01-preview' = {
  parent: holidaysApi
  properties: {
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
    request: {
      queryParameters: []
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
            sample: '[\r\n  {\r\n    "name": "New Year\'s Day",\r\n    "name_local": "",\r\n    "language": "",\r\n    "description": "",\r\n    "country": "US",\r\n    "location": "United States",\r\n    "type": "National",\r\n    "date": "01/01/2020",\r\n    "date_year": "2020",\r\n    "date_month": "01",\r\n    "date_day": "01",\r\n    "week_day": "Wednesday"\r\n  },\r\n  {\r\n    "name": "World Braille Day",\r\n    "name_local": "",\r\n    "language": "",\r\n    "description": "",\r\n    "country": "US",\r\n    "location": "United States",\r\n    "type": "Worldwide",\r\n    "date": "01/04/2020",\r\n    "date_year": "2020",\r\n    "date_month": "01",\r\n    "date_day": "04",\r\n    "week_day": "Saturday"\r\n  },\r\n  {\r\n    "name": "Epiphany",\r\n    "name_local": "",\r\n    "language": "",\r\n    "description": "",\r\n    "country": "US",\r\n    "location": "United States",\r\n    "type": "Christian",\r\n    "date": "01/06/2020",\r\n    "date_year": "2020",\r\n    "date_month": "01",\r\n    "date_day": "06",\r\n    "week_day": "Monday"\r\n  },\r\n  {\r\n    "name": "International Programmers\' Day",\r\n    "name_local": "",\r\n    "language": "",\r\n    "description": "",\r\n    "country": "US",\r\n    "location": "United States",\r\n    "type": "Worldwide",\r\n    "date": "01/07/2020",\r\n    "date_year": "2020",\r\n    "date_month": "01",\r\n    "date_day": "07",\r\n    "week_day": "Tuesday"\r\n  }\r\n]'
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'HolidayResponseStructure'
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
            schemaId: '65f2d0c65ddd1724c4ff786f'
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
            schemaId: '65f2d0c65ddd1724c4ff786f'
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
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'MethodNotAllowedErrorReponseStructure'
          }
        ]
      }
      {
        statusCode: 500
        description: 'Internal Server Error'
        headers: []
        representations: [
          {
            contentType: 'application/json'
            sample: '{\r\n  "httpCode": "500",\r\n  "httpMessage": "Internal Server Error",\r\n  "moreInformation": "Long error message"\r\n}'
            schemaId: '65f2d0c65ddd1724c4ff786f'
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
            schemaId: '65f2d0c65ddd1724c4ff786f'
            typeName: 'ConnectionErrorReponseStructure'
          }
        ]
      }
    ]
    displayName: 'This operation is used to get holiday details of any country based on their country code and year.'
    method: 'GET'
    urlTemplate: '/?country={country}&year={year}&month={month}&day={day}'
  }
  name: 'get-holidays-country-country-year-year-month-month-day-day'
  dependsOn: [
    ApimServiceName_holidays_api_65f2d0c65ddd1724c4ff786f
  ]
}

resource ApimServiceName_holidays_api_policy 'Microsoft.ApiManagement/service/apis/policies@2021-01-01-preview' = {
  parent: holidaysApi
  properties: {
    value: loadTextContent('holidays-api-apiPolicy.xml')
    format: 'xml'
  }
  name: 'policy'
}

resource openAiProductLink 'Microsoft.ApiManagement/service/products/apiLinks@2023-03-01-preview' = {
  name: 'holidaysProduct-apilink'
  parent: holidaysProduct
  properties: {
    apiId: holidaysApi.id
  }
}

resource openAiSubscription 'Microsoft.ApiManagement/service/subscriptions@2023-03-01-preview' = {
  name: '${apimServiceName}/holidays-subscription'
  properties: {
    scope: holidaysProduct.id
    displayName: 'Open Ai Subscription'
    state: 'active'
    allowTracing: false
  }
}
