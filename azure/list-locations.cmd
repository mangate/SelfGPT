az account list-locations --query "[?metadata.regionCategory=='Recommended'].{name:regionalDisplayName,code:name}" --output table
