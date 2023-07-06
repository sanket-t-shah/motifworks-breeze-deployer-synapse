$location = 'eastus'
$resourceGroupName = 'rg-breeze-dev'

$commandText = "
        az ``
            group ``
            create ``
            --location $($location) ``
            --name $($resourceGroupName)"

Invoke-Expression $commandText

az deployment group create `
    --resource-group $resourceGroupName `
    --name "breeze-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')" `
    --parameters azuredeploy.parameters.json `
    --template-file azuredeploy.json
