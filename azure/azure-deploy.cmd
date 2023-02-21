@echo off
set /p "response=Do you want to create a new resource group? (y/n): "
set /p "resourceGroupName=Enter the name of the resource group: "

SET AZURE_FREE_PLAN_ID=none
SET CMD=az appservice plan list --query "[?sku.name=='F1' && sku.capacity>`0`].id | [0]" --output tsv 2^^^>nul
FOR /F "tokens=* USEBACKQ" %%F IN (`%CMD%`) DO (
  SET AZURE_FREE_PLAN_ID=%%F
  ECHO[
  echo Found existing free app service plan, using it.
  ECHO[
)

if %AZURE_FREE_PLAN_ID%==none (
  ECHO[
  echo Free plan not found, will create one.
  ECHO[
)

echo Deploment started >azure-deploy.log

if %response%==y (
  ECHO[
  call list-locations.cmd
  ECHO[
  set /p "location=Enter the location code: "
  echo Press enter to create resource group %resourceGroupName% in location %location%
  ECHO[
  pause
  echo az group create -l %location% -n %resourceGroupName% >>azure-deploy.log
  call az group create -l %location% -n %resourceGroupName% >>azure-deploy.log
  echo Created.
)

call az bicep build --file main.bicep 2>nul

set /p "webAppName=Enter the desired app name (must be unique across azure): "
set /p "openAiKey=Enter your open AI key: "
set imageTag=paviad/selfgpt:v5
set /p "imageTag=Enter the image tag to use (press enter for %imageTag%): "

ECHO[
echo [92m[1m
echo az deployment group create --template-file main.json --resource-group %resourceGroupName% --parameters "serverFarmId=%AZURE_FREE_PLAN_ID%" --parameters "webAppName=%webAppName%" --parameters "openAiKey=%openAiKey%" --parameters "imageTag=%imageTag%"
echo [0m[37m
ECHO[
echo az deployment group create --template-file main.json --resource-group %resourceGroupName% --parameters "serverFarmId=%AZURE_FREE_PLAN_ID%" --parameters "webAppName=%webAppName%" --parameters "openAiKey=%openAiKey%" --parameters "imageTag=%imageTag%" >>azure-deploy.log
echo Press enter to create azure resources.
ECHO[
pause
az deployment group create --template-file main.json --resource-group %resourceGroupName% --parameters "serverFarmId=%AZURE_FREE_PLAN_ID%" --parameters "webAppName=%webAppName%" --parameters "openAiKey=%openAiKey%" --parameters "imageTag=%imageTag%" >>azure-deploy.log
echo Done, output is in azure-deploy.log
