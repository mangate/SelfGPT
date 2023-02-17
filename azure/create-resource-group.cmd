@ECHO OFF
ECHO About to run
ECHO az group create -l %1 -n %2
pause
az group create -l %1 -n %2
