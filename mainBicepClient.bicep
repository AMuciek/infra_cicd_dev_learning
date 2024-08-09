param location string = resourceGroup().location
param azureOpenAILocation string = 'swedencentral'
param clientName string = 'client'
param environmentType string = 'poc'

param deploymentTags object = {
  client:clientName
  project: 'testProject'
}

// Azure OpenAI
var clientInResourceNames = substring(toLower(clientName), 0, 10)
var azureOpenAIName = 'oai-${clientInResourceNames}-${environmentType}-002'
var azureAISearchName = 'srch-${clientInResourceNames}-${environmentType}-002'
var azureStorageAccountName = 'sa${clientInResourceNames}${environmentType}001'
var appServicePlanName = 'apps-${clientInResourceNames}-${environmentType}-001'
var appServiceAppName = 'apps-${clientInResourceNames}-${environmentType}-001'

resource azureOpenAI 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: azureOpenAIName
  location: azureOpenAILocation
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: azureOpenAIName
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
  }
  tags: deploymentTags
}

// OpenAI models

var modelConfigs = [
  {
    name: 'gpt-4'
    capacity: 2
    version: '0613'
  }
  {
    name: 'gpt-4o'
    capacity: 2
    version: '2024-05-13'
  }
  {
    name:  'text-embedding-ada-002'
    capacity: 2
    version: '2'
  }
]

@batchSize(1) //to make below execution sequential
resource azureOpenAIModels 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = [for modelConfig in modelConfigs:{ 
  parent: azureOpenAI
  name: modelConfig.name
  sku: {
    name: 'Standard'
    capacity: modelConfig.capacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelConfig.name
      version: modelConfig.version
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.Default'
  }
  tags: deploymentTags

}]


output azureOpenAIEndpoint string = azureOpenAI.properties.endpoint

// Azure Storage

resource azureStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: azureStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  tags:deploymentTags
}


// Azure Inteligent Search
resource azureAISearch 'Microsoft.Search/searchServices@2023-11-01'= {
  name: azureAISearchName
  location: location
  sku:{
    name: 'free'
  }
  tags:deploymentTags
}


// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01'= {
  name: appServicePlanName
  location: location
  sku:{
    name: 'F1'
  }
  tags:deploymentTags
}

// Web App
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
  tags:deploymentTags
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName

