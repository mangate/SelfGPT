// This is a Bicep template for SelfGPT Bot Web App for Azure - the @..@ placeholders will be replaced by the deployment script

param webAppName string
param sku string = 'F1' // The SKU of App Service Plan
param linuxFxVersion string = 'DOCKER|paviad/selfgpt:v5' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
var appServicePlanName = toLower('AppServicePlan-${webAppName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

@description('SelfGPT Bot Web App for Azure')
resource myselfgptbot 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  kind: 'app,linux,container'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}

module appSettings 'appSettings.bicep' = {
  name: '${webAppName}-appSettings'
  params: {
    webAppName: webAppName
    currentAppSettings: list(resourceId('Microsoft.Web/sites/config', webAppName, 'appsettings'), '2022-03-01').properties
    appSettings: {
      DOCKER_ENABLE_CI: 'true'
      DOCKER_REGISTRY_SERVER_URL: 'https://index.docker.io/v1'
      WEBSITES_PORT: '5000'
      SELFGPT_AZURE: 'TRUE'
      CONFIG__AZURE__BLOBNAME: '@CONFIG__AZURE__BLOBNAME@'
      CONFIG__AZURE__CONTAINERNAME: '@CONFIG__AZURE__CONTAINERNAME@'
      CONFIG__AZURE__CONNECTIONSTRING: '@CONFIG__AZURE__CONNECTIONSTRING@'
      CONFIG__DEPLOYMENT: 'azure'
      CONFIG__OPENAI_KEY: '@CONFIG__OPENAI_KEY@'
    }
  }
}
