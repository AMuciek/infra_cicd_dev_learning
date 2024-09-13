To deploy the services in portal, open CLI, upload `mainBicepClient.bicep` file and run the command:
```{azurecli}
az deployment group create --name chatbotAppDeployment --resource-group rg-infranetwork-training --template-file mainBicepClient.bicep --parameters clientName=testClientChatbot
```