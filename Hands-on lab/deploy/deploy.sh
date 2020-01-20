
#!/bin/bash

rgName=${1:-$(az group list --query [0].name -o tsv)}
rgLocation=${2:-$(az group list --query [0].location -o tsv)} 
templateUri=https://raw.githubusercontent.com/shoegazerpt/MCW-Serverless-architecture/btf2020/Hands-on%20lab/deploy/azureDeploy.json
tenantId=$(az account show --query tenantId -o tsv)
userId=$(az ad signed-in-user show --query objectId -o tsv)

echo $rgName $rgLocation $templateUri

echo ""
echo "Creating deployment (ignore if error)..."
az group deployment create -n deploy -g $rgName --template-uri $templateUri --parameters "{\"tenantId\":{\"value\":\"$tenantId\"},\"userId\":{\"value\":\"$userId\"}}"

echo ""
echo "Creating deployment 2..."
az group deployment create -n deploy -g $rgName --template-uri $templateUri --parameters "{\"tenantId\":{\"value\":\"$tenantId\"},\"userId\":{\"value\":\"$userId\"}}"

echo ""
echo "Getting outputs..."
az group deployment show -n deploy -g $rgName --query properties.outputs > appsettings.json
jq 'to_entries | map_values({ name: .key } + {slotSetting: false} + {value: .value.value})' appsettings.json > appsettings.txt
#jq  -r 'to_entries|map("\(.key)=\(.value.value|tostring) ")|.[]' appsettings.json > appsettings.txt

tollBoothFunctionName=$(jq -r '.[] | select(.name == "tollBoothFunctionName") | .value' appsettings.txt)

blobStorageConnectionPlain=$(jq -r '.[] | select(.name == "blobStorageConnectionPlain") | .value' appsettings.txt)
echo ""
echo "Blob storage connection: ${blobStorageConnectionPlain}"

echo "cd \"MCW-Serverless-architecture/Hands-on lab/starter/TollBooth/UploadImagesCore\" && dotnet run -- \"${blobStorageConnectionPlain}\" \"../../license plates\" && cd ~" > uploadImages.sh
chmod +x uploadImages.sh

# functionapp settings
echo ""
echo "Setting function appsettings..."
az functionapp config appsettings set -g $rgName -n $tollBoothFunctionName --settings @appsettings.txt

# functionapp restart
echo ""
echo "Restarting functions..."
az functionapp restart -g $rgName -n $tollBoothFunctionName

# functionapp restart
echo ""
echo "Cloning repo..."
git clone https://github.com/shoegazerpt/MCW-Serverless-architecture.git
cd "MCW-Serverless-architecture/Hands-on lab/starter/TollBooth/TollBooth"

echo ""
echo "Current folder: "
pwd
ls -la

echo ""
echo "Pausing 30 secs..."
sleep 30

# publish functions
echo ""
echo "Publishing functions"
func azure functionapp publish $tollBoothFunctionName

