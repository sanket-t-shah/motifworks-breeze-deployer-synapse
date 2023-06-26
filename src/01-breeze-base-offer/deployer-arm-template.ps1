$location = 'eastus2'
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
    --parameters mainTemplate.parameters.json `
    --template-file mainTemplate.json
