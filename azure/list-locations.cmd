az account list-locations --query "[?metadata.regionCategory=='Recommended'].name" --output tsv
