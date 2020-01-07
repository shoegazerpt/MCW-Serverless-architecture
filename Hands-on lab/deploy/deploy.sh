
#!/bin/bash
rgName=${1:-$(az group list --query [0].name -o tsv)}
rgLocation=${2:-$(az group list --query [0].location -o tsv)} 
templateFile=${3:-}
# tenantId=$(az account show --query tenantId -o tsv)
# userId=$(az ad signed-in-user show --query objectId -o tsv)

echo $rgName $rgLocation

# az group deployment create -n deploy -g $rgName --template-file $templateFile --parameters "{\"tenantId\":{\"value\":\"$tenantId\"},\"userId\":{\"value\":\"$userId\"}}"

