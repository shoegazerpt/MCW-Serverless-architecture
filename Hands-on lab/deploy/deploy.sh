
#!/bin/bash
rgName=${1:-$(az group list --query [0].name -o tsv)}
rgLocation=${2:-$(az group list --query [0].location -o tsv)} 
templateUri=https://raw.githubusercontent.com/shoegazerpt/MCW-Serverless-architecture/btf2020/Hands-on%20lab/deploy/azureDeploy.json
tenantId=$(az account show --query tenantId -o tsv)
userId=$(az ad signed-in-user show --query objectId -o tsv)

echo $rgName $rgLocation $templateFile

az group deployment create -n deploy -g $rgName --template-uri $templateFile --parameters "{\"tenantId\":{\"value\":\"$tenantId\"},\"userId\":{\"value\":\"$userId\"}}"

# functionapp settings