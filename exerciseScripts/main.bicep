// Azure storage
param location string = resourceGroup().location
param appServiceAppName string = 'app-toyappservice-webapp-001'


@allowed([
  'nonprod'
  'prod'
])
param environmentType string
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

param resourceTags object = {
  created_by: 'AMuciek'
  purpose: 'training'
  deployment_method: 'bicep'
  environment_type: environmentType
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'satoystorage001'
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  properties: {
    accessTier: 'Hot'
  }
  tags: resourceTags
}

module appService 'appService.bicep'={
  name: 'appService'
  params: {
    location:location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
