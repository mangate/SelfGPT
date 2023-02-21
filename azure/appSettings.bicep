param webAppName string
param appSettings object
param currentAppSettings object

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: '${webAppName}/appsettings'
  properties: union(currentAppSettings, appSettings)
}
