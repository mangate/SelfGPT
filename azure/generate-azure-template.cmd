@echo off
SET CMD=az appservice plan list --query "[?sku.name=='F1' && sku.capacity>`0`].id | [0]" --output tsv 2^^^>nul
FOR /F "tokens=* USEBACKQ" %%F IN (`%CMD%`) DO (
SET AZURE_FREE_PLAN_ID=%%F
)

if %AZURE_FREE_PLAN_ID%=="" (
    ECHO No free plan found
    ECHO[
    copy main-create-new.bicep main.bicep >nul
) ELSE (
    ECHO Free plan found: %AZURE_FREE_PLAN_ID%
    ECHO[
    copy main-use-existing.bicep main.bicep >nul
    @REM sed -i s,@@@,%AZURE_FREE_PLAN_ID%,g main.bicep
)

call python inject-secrets.py
call az bicep build --file main.bicep 2>nul
ECHO[
ECHO Azure resource template main.json generated
ECHO[
ECHO ================================
ECHO To deploy run:
echo [92m[1m
ECHO    az deployment group create --template-file main.json --resource-group ^<^<resource group name^>^>
echo [0m[37m
ECHO ================================
ECHO[
ECHO If you want to create a resource group, run [92m[1mcreate-resource-group ^<^<location^>^> ^<^<resource group name^>^>[0m[37m
ECHO[
ECHO To get a list of recommended locations run [92m[1mlist-locations[0m[37m
