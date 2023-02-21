// This is a Bicep template for SelfGPT Bot Web App for Azure - the @..@ placeholders will be replaced by the deployment script

param webAppName string
param openAiKey string
param imageTag string
param linuxFxVersion string = 'DOCKER|${imageTag}' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources
param serverFarmId string
param sku string = 'F1' // The SKU of App Service Plan
var appServicePlanName = toLower('AppServicePlan-${webAppName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = if (serverFarmId == 'none') {
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
    serverFarmId: serverFarmId == 'none' ? appServicePlan.id : serverFarmId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}

resource selfgptStorage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'Storage'
  name: toLower(replace('${webAppName}storage','-',''))
  location: location
}

var connStr = 'DefaultEndpointsProtocol=https;AccountName=${selfgptStorage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(selfgptStorage.id, selfgptStorage.apiVersion).keys[0].value}'

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
      CONFIG__AZURE__BLOBNAME: 'theblob'
      CONFIG__AZURE__CONTAINERNAME: 'selfgpt'
      CONFIG__AZURE__CONNECTIONSTRING: connStr
      CONFIG__DEPLOYMENT: 'azure'
      CONFIG__OPENAI_KEY: openAiKey
    }
  }
}
