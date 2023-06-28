param (
    [Parameter(Mandatory = $false)][string]$resourceGroupName,
    [Parameter(Mandatory = $false)][string]$location,
    [Parameter(Mandatory = $false)][string]$storageAccountName,
    [Parameter(Mandatory = $false)][string]$synapseWorkspaceName,
    [Parameter(Mandatory = $false)][string]$synapseAdminUsername,
    [Parameter(Mandatory = $false)][string]$synapseAdminPassword,
    [Parameter(Mandatory = $false)][string]$synapseDedicatedPoolName,
    [Parameter(Mandatory = $false)][string]$synapseDedicatedPoolSize,
    [Parameter(Mandatory = $false)][string]$synapseAADAdministratorGuid,
    [Parameter(Mandatory = $false)][string]$purviewAccountName,
    [Parameter(Mandatory = $false)][string]$tagsSynapseWorkspace,
    [Parameter(Mandatory = $false)][string]$tagsSynapseDedicatedPool,
    [Parameter(Mandatory = $false)][string]$tagsPurviewAccount
)

class BreezeParameters {
    # There should be EXACTLY 1 Subscription ID available for going further.
    [string]$SubscriptionId

    # Resource Group Name where Synapse instance should be forked.
    [string]$ResourceGroupName

    # Location where Synapse Instance should be created.
    [string]$Location

    # Storage Account Name that Synapse should use.
    [string]$StorageAccountName

    # Provide Synapse Workspace Name to be used.
    [string]$SynapseWorkspaceName

    # Provide Synapse Administrator Username.
    [string]$SynapseAdminUsername

    # Provide Synapse Administrator Password.
    [string]$SynapseAdminPassword

    # Provide Name for SQL Dedicated Pool.
    [string]$SynapseDedicatedPoolName

    # Provide Size for SQL Dedicated Pool.
    [string]$SynapseDedicatedPoolSize

    # GUID of AAD User who should be made as "Synapse Administrator" in Synapse RBAC Roles.
    [string]$SynapseAADAdministratorGuid

    # Provide Purview Account Name to be used.
    [string]$PurviewAccountName

    # JSON Tags String for Synapse Workspace.
    [string]$TagsSynapseWorkspace

    # JSON Tags String for Synapse Dedicated Pool.
    [string]$TagsSynapseDedicatedPool

    # JSON Tags String for Purview Account.
    [string]$TagsPurviewAccount

    [string] ToString() {
        return "
Resources:
----------
Subscription ID                : $($this.SubscriptionId)
Resource Group Name            : $($this.ResourceGroupName)
Location                       : $($this.Location)
Storage Account Name           : $($this.StorageAccountName)
Synapse Workspace Name         : $($this.SynapseWorkspaceName)
Synapse Administrator Username : $($this.SynapseAdminUsername)
Synapse Administrator Password : $($this.SynapseAdminPassword)
Dedicated Pool Name            : $($this.SynapseDedicatedPoolName)
Dedicated Pool Size            : $($this.SynapseDedicatedPoolSize)
Synapse AAD Administrator GUID : $($this.SynapseAADAdministratorGuid)
Purview Account Name           : $($this.PurviewAccountName)
Tags: Synapse Workspace        : $($this.tagsSynapseWorkspace)
Tags: Synapse Dedicated Pool   : $($this.TagsSynapseDedicatedPool)
Tags: Purview Account          : $($this.TagsPurviewAccount)
"
    }
}

class DeploymentManager {
    hidden [string]$accessTokenSynapse = ''
    hidden [string]$accessTokenPurview = ''
    hidden [string]$accessTokenDatabase = ''
    hidden [BreezeParameters]$parameters = [BreezeParameters]::new()
    hidden [DateTime]$startedOn = (Get-Date)
    hidden [DateTime]$endedOn = (Get-Date)

    DeploymentProcessor(
        [string]$resourceGroupName
        , [string]$location
        , [string]$storageAccountName
        , [string]$synapseWorkspaceName
        , [string]$synapseAdminUsername
        , [string]$synapseAdminPassword
        , [string]$synapseDedicatedPoolName
        , [string]$synapseDedicatedPoolSize
        , [string]$synapseAADAdministratorGuid
        , [string]$purviewAccountName
        , [string]$tagsSynapseWorkspace
        , [string]$tagsSynapseDedicatedPool
        , [string]$tagsPurviewAccount) {
        Write-Host `
            -NoNewline `
            -Object '
+-------------------------------------------+
|     Motifworks BREEZE Assets Deployer     |
+-------------------------------------------+
'

        $this.LoginAndSetSubscription()
        $this.startedOn = (Get-Date)

        $this.parameters.ResourceGroupName = $resourceGroupName
        $this.parameters.Location = $location
        $this.parameters.StorageAccountName = $storageAccountName
        $this.parameters.SynapseWorkspaceName = $synapseWorkspaceName
        $this.parameters.SynapseAdminUsername = $synapseAdminUsername
        $this.parameters.SynapseAdminPassword = $synapseAdminPassword
        $this.parameters.SynapseDedicatedPoolName = $synapseDedicatedPoolName
        $this.parameters.SynapseDedicatedPoolSize = $synapseDedicatedPoolSize
        $this.parameters.SynapseAADAdministratorGuid = $synapseAADAdministratorGuid
        $this.parameters.PurviewAccountName = $purviewAccountName
        $this.parameters.TagsSynapseWorkspace = $tagsSynapseWorkspace
        $this.parameters.TagsSynapseDedicatedPool = $tagsSynapseDedicatedPool
        $this.parameters.TagsPurviewAccount = $tagsPurviewAccount
        
        $this.parameters.ToString()
        $this.CreateInstanceSynapse()
        $this.PrepareAndUploadAssetsSynapse()
        $this.CreateInstancePurview()
        $this.PrepareAndUploadAssetsPurview()
        $this.SetSynapsePurviewIntegration()
        $this.endedOn = (Get-Date)
        $totalTime = $this.endedOn - $this.startedOn
        Write-Host "Total Time Taken: $($totalTime.Minutes) min $($totalTime.Seconds) sec"
    }

    hidden LoginAndSetSubscription() {
        # Perform Logon on Azure.
        az `
            login `
            --identity `
            --only-show-errors

        # Get list of all Subscriptions for logged in User.
        $subscriptions = az `
            account `
            subscription `
            list `
            --only-show-errors | ConvertFrom-Json

        # This is scenario of ONLY 1 Subscription. Pick-up default value and use it.
        $this.parameters.SubscriptionId = $subscriptions[0].subscriptionId
    }

    hidden ShowParameters() {
        # Show all provided values.
        Write-Host `
            "Provided Values: 
            $($this.parameters.ToString())"
    }

    hidden [string] GetTags([string] $tagsString) {
        $returnValue = ''

        $tagsString = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($tagsString))

        $($tagsString | ConvertFrom-Json).PSObject.Properties | ForEach-Object { 
            $returnValue = $returnValue + "'$($_.Name)=$($_.Value)' "
        } 

        return $returnValue
    }

    hidden CreateInstanceSynapse() {
        Write-Host `
            -Object 'Creating Synapse Workspace...'
        $commandText = "
        az synapse workspace create ``
            --only-show-errors ``
            --name $($this.parameters.SynapseWorkspaceName) ``
            --managed-rg-name mrg-$($this.parameters.SynapseWorkspaceName) ``
            --resource-group $($this.parameters.ResourceGroupName) ``
            --storage-account $($this.parameters.StorageAccountName) ``
            --sql-admin-login-user $($this.parameters.SynapseAdminUsername) ``
            --sql-admin-login-password $($this.parameters.SynapseAdminPassword) ``
            --location $($this.parameters.Location) ``
            --file-system $($this.parameters.SynapseWorkspaceName) ``
            --tags $($this.GetTags($this.parameters.TagsSynapseWorkspace))"

        Write-Host $commandText

        Invoke-Expression $commandText

        Write-Host `
            -Object 'Opening Firewall (For Azure)...'
        az synapse workspace firewall-rule create `
            --only-show-errors `
            --name AllowAllWindowsAzureIps `
            --workspace-name $this.parameters.SynapseWorkspaceName `
            --resource-group $this.parameters.ResourceGroupName `
            --start-ip-address 0.0.0.0 `
            --end-ip-address 0.0.0.0

        Write-Host `
            -Object 'Opening Firewall (For Everyone)...'
        az synapse workspace firewall-rule create `
            --only-show-errors `
            --name allowAll `
            --workspace-name $this.parameters.SynapseWorkspaceName `
            --resource-group $this.parameters.ResourceGroupName `
            --start-ip-address 0.0.0.0 `
            --end-ip-address 255.255.255.255

        Write-Host `
            -Object 'Assigning "Synapse Administrator" Role...'
        az synapse role assignment create `
            --only-show-errors `
            --role 'Synapse Administrator' `
            --assignee-principal-type 'User' `
            --workspace-name $this.parameters.SynapseWorkspaceName `
            --assignee-object-id $this.parameters.SynapseAADAdministratorGuid

        Write-Host `
            -Object 'Creating Dedicated Pool Instance...'
        $commandText = "
        az synapse sql pool create ``
            --only-show-errors ``
            --name $($this.parameters.SynapseDedicatedPoolName) ``
            --performance-level $($this.parameters.SynapseDedicatedPoolSize) ``
            --workspace-name $($this.parameters.SynapseWorkspaceName) ``
            --resource-group $($this.parameters.ResourceGroupName) ``
            --tags $($this.GetTags($this.parameters.TagsSynapseDedicatedPool))"


        Write-Host $commandText

        Invoke-Expression $commandText
    }

    hidden PrepareAndUploadAssetsSynapse() {
        # Create strings that are used in replacments in Datasets and Pipelines.
        $defaultLinkedServiceNameSynapse = "$($this.parameters.SynapseWorkspaceName)-WorkspaceDefaultSqlServer"
        $defaultLinkedServiceNameStorage = "$($this.parameters.SynapseWorkspaceName)-WorkspaceDefaultStorage"

        try {
            Write-Host `
                -Object 'Creating Tables in Azure Synapse...'
            
            Invoke-Sqlcmd `
                -InputFile './breeze-ddl.sql' `
                -ServerInstance "$($this.parameters.SynapseWorkspaceName).sql.azuresynapse.net" `
                -Database 'syndpbreeze' `
                -Username $this.parameters.SynapseAdminUsername `
                -Password $this.parameters.SynapseAdminPassword
        }
        catch {
            Write-Host `
                -Object "An error occurred while creating DB Objects (Table and Stored Procedures) in Synapse. Error Stack: $($_)"
        }

        # This is necessary as Tokens expire much frequently.
        $this.RefreshAccessTokens()

        # Creating Azure Synapse Datasets.
        Write-Host `
            -Object '
Creating Datasets in Azure Synapse...'

        # Get list of all Datasets from Local Computer.
        $datasets = Get-ChildItem ds*.json | Select-Object BaseName

        # Iterate over Datasets and create each separately.
        foreach ($currentDataset in $datasets) {
            try {
                Write-Host `
                    -Object "Creating Dataset: $($currentDataset.BaseName)"

                # Read all file contents.
                $fileContents = Get-Content `
                    -Raw `
                    -Path "./$($currentDataset.BaseName).json"

                # Perform Replacements.
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_SYNAPSE}}', $defaultLinkedServiceNameSynapse)
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_STORAGE}}', $defaultLinkedServiceNameStorage)

                for ($retryCounter = 1; $retryCounter -le 3; $retryCounter++) {
                    $success = $false

                    try {
                        # Create Dataset on Azure Synapse.
                        Invoke-RestMethod `
                            -Uri "https://$($this.parameters.SynapseWorkspaceName).dev.azuresynapse.net/datasets/$($currentDataset.BaseName)?api-version=2021-06-01" `
                            -Method PUT `
                            -Body $fileContents `
                            -Headers @{ Authorization = "Bearer $($this.accessTokenSynapse)" } `
                            -ContentType 'application/json'

                        $success = $true
                    }
                    catch {
                        
                    }

                    if ($success -eq $true) {
                        break
                    }
                }
            }
            catch {
                Write-Host `
                    -Object "An error occurred while publishing Dataset: $($currentDataset.BaseName). Error Stack: $($_)"
            }
        }

        # This is necessary as Tokens expire much frequently.
        $this.RefreshAccessTokens()

        # Creating Azure Synapse Notebooks.
        Write-Host `
            -Object '
Creating Notebooks in Azure Synapse...'

        # Get list of all Notebooks from Local Computer.
        $notebooks = Get-ChildItem *.ipynb | Select-Object BaseName

        # Iterate over Notebooks and create each separately.
        foreach ($currentNotebook in $notebooks) {
            try {
                Write-Host `
                    -Object "Creating Notebook: $($currentNotebook.BaseName)"

                # Read all file contents.
                $fileContents = Get-Content `
                    -Raw `
                    -Path "./$($currentNotebook.BaseName).ipynb"

                # Perform Replacements.
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_SYNAPSE}}', $defaultLinkedServiceNameSynapse)
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_STORAGE}}', $defaultLinkedServiceNameStorage)
                $fileContents = $fileContents.Replace('{{SYNPAPSE_WORKSPACE_NAME}}', $this.parameters.SynapseWorkspaceName)
                $fileContents = $fileContents.Replace('{{BREEZE_ADMIN_USERNAME}}', $this.parameters.SynapseAdminUsername)
                $fileContents = $fileContents.Replace('{{BREEZE_ADMIN_PASSWORD}}', $this.parameters.SynapseAdminPassword)

                for ($retryCounter = 1; $retryCounter -le 3; $retryCounter++) {
                    $success = $false

                    try {
                        # Create Notebook on Azure Synapse.
                        Invoke-RestMethod `
                            -Uri "https://$($this.parameters.SynapseWorkspaceName).dev.azuresynapse.net/notebooks/$($currentNotebook.BaseName)?api-version=2021-06-01" `
                            -Method PUT `
                            -Body $fileContents `
                            -Headers @{ Authorization = "Bearer $($this.accessTokenSynapse)" } `
                            -ContentType 'application/json'
                    }
                    catch {
                        
                    }

                    if ($success -eq $true) {
                        break
                    }
                }
            }
            catch {
                Write-Host `
                    -Object "An error occurred while publishing Notebook: $($currentNotebook.BaseName). Error Stack: $($_)"
            }
        }

        # This is necessary as Tokens expire much frequently.
        $this.RefreshAccessTokens()

        # Creating Azure Synapse Pipelines.
        Write-Host `
            -Object '
Creating Pipelines in Azure Synapse...'

        # Get list of all Pipelines from Local Computer.
        $pipelines = Get-ChildItem p*.json | Select-Object BaseName

        # Iterate over Pipelines and create each separately.
        foreach ($currentPipeline in $pipelines) {
            try {
                Write-Host `
                    "Creating Pipeline: $($currentPipeline.BaseName)"

                # Read all file contents.
                $fileContents = Get-Content `
                    -Raw `
                    -Path "./$($currentPipeline.BaseName).json"

                # Perform Replacements.
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_SYNAPSE}}', $defaultLinkedServiceNameSynapse)
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_STORAGE}}', $defaultLinkedServiceNameStorage)

                for ($retryCounter = 1; $retryCounter -le 3; $retryCounter++) {
                    $success = $false

                    try {
                        # Create Pipeline on Azure Synapse.
                        Invoke-RestMethod `
                            -Uri "https://$($this.parameters.SynapseWorkspaceName).dev.azuresynapse.net/pipelines/$($currentPipeline.BaseName)?api-version=2021-06-01" `
                            -Method PUT `
                            -Body $fileContents `
                            -Headers @{ Authorization = "Bearer $($this.accessTokenSynapse)" } `
                            -ContentType 'application/json'
                    }
                    catch {
                        
                    }

                    if ($success -eq $true) {
                        break
                    }
                }
            }
            catch {
                Write-Host `
                    -Object "An error occurred while publishing Pipeline: $($currentPipeline.BaseName). Error Stack: $($_)"
            }
        }
    }

    hidden CreateInstancePurview() {
        # Create Purview Account manually.
        Write-Host `
            -Object 'Creating Purview Account...'
        $commandText = "
        az purview account create ``
            --account-name $($this.parameters.PurviewAccountName) ``
            --managed-group-name mrg-$($this.parameters.PurviewAccountName) ``
            --resource-group $($this.parameters.ResourceGroupName) ``
            --location $($this.parameters.Location) ``
            --public-network-access Enabled ``
            --tags $($this.GetTags($this.parameters.TagsPurviewAccount))"

        Write-Host $commandText

        Invoke-Expression $commandText

        # Wait for Purview account to be created completely.
        # This is necessary step as above command exits without waiting for Purview Account to be setup completely.
        Write-Host `
            -Object 'Waiting for Purview Account to be created...'
        az purview account wait `
            --created `
            --name $this.parameters.PurviewAccountName `
            --resource-group $this.parameters.ResourceGroupName

        # Add Provider User GUID as Collection Administrator.
        # It's necessary to add other Purview Roles manually from Purview Portal: https://web.purview.azure.com/
        # Above manual step is necessary as CLI doesn't allow yet to assign Purview specific Roles.
        Write-Host `
            -Object 'Adding User as Purview Root Collection Administrator...'
        az purview account add-root-collection-admin `
            --name $this.parameters.PurviewAccountName `
            --resource-group $this.parameters.ResourceGroupName `
            --object-id $this.parameters.SynapseAADAdministratorGuid `
            --verbose

        # If we don't wait, user with GUID mentioned in above command won't see Purview access.
        # This seems more of a bug on Purview side rather than on this script side.
        Write-Host `
            -Object 'Waiting for Purview Account to be updated...'
        az purview account wait `
            --updated `
            --name $this.parameters.PurviewAccountName `
            --resource-group $this.parameters.ResourceGroupName
    }

    hidden PrepareAndUploadAssetsPurview() {
        # Set the collection names to be created in Purview.
        $collectionNameADLS = 'BREEZE-Data-Lake-Storage'
        $collectionNameSynapse = 'BREEZE-Synapse'

        # Set the default body to indicate that above named collections should be placed under Root.
        $body = @{
            parentCollection = @{
                referenceName = $this.parameters.PurviewAccountName
            }
        }

        # Convert to JSON Object.
        $body = $body | ConvertTo-Json
  
        # Refresh all Access Tokens.
        $this.RefreshAccessTokens()

        Write-Host `
            -Object 'Creating Collection for Storage Account...'

        # Create Collection for Storage Account.
        $uri = "https://$($this.parameters.PurviewAccountName).purview.azure.com/account/collections/$($collectionNameADLS)?api-version=2019-11-01-preview"
        Invoke-RestMethod `
            -Uri $uri `
            -Method PUT `
            -Body $body `
            -Headers @{ Authorization = "Bearer $($this.accessTokenPurview)" } `
            -ContentType 'application/json'

        # Refresh all Access Tokens.
        $this.RefreshAccessTokens()

        Write-Host `
            -Object 'Creating Collection for Synapse...'

        # Create Collection for Synapse.
        $uri = "https://$($this.parameters.PurviewAccountName).purview.azure.com/account/collections/$($collectionNameSynapse)?api-version=2019-11-01-preview"
        Invoke-RestMethod `
            -Uri $uri `
            -Method PUT `
            -Body $body `
            -Headers @{ Authorization = "Bearer $($this.accessTokenPurview)" } `
            -ContentType 'application/json'

        # Create Request Body for creating Purview Source for ADLS.
        $body = @{
            kind       = 'AdlsGen2'
            properties = @{
                endpoint       = "https://$($this.parameters.StorageAccountName).dfs.core.windows.net/"
                subscriptionId = $this.parameters.SubscriptionId
                resourceGroup  = $this.parameters.ResourceGroupName
                location       = $this.parameters.Location
                resourceName   = $this.parameters.StorageAccountName
                collection     = @{
                    type          = 'CollectionReference'
                    referenceName = $collectionNameADLS
                }
            }
        }
  
        # Convert to JSON Object.
        $body = $body | ConvertTo-Json
  
        # Refresh all Access Tokens.
        $this.RefreshAccessTokens()

        Write-Host `
            -Object 'Creating Purview Source for ADLS...'

        # Create Source for ADLS.
        $uri = "https://$($this.parameters.PurviewAccountName).purview.azure.com/scan/datasources/$($collectionNameADLS)?api-version=2022-07-01-preview"
        Invoke-RestMethod `
            -Uri $uri `
            -Method PUT `
            -Body $body `
            -Headers @{ Authorization = "Bearer $($this.accessTokenPurview)" } `
            -ContentType 'application/json'

        # Create Request Body for creating Purview Source for Synapse.
        $body = @{
            kind       = 'AzureSynapseWorkspace'
            properties = @{
                dedicatedSqlEndpoint  = "$($this.parameters.SynapseWorkspaceName).sql.azuresynapse.net"
                serverlessSqlEndpoint = "$($this.parameters.SynapseWorkspaceName)-ondemand.sql.azuresynapse.net"
                subscriptionId        = $this.parameters.SubscriptionId
                resourceGroup         = $this.parameters.ResourceGroupName
                location              = $this.parameters.Location
                resourceName          = $this.parameters.SynapseWorkspaceName
                collection            = @{
                    type          = 'CollectionReference'
                    referenceName = $collectionNameSynapse
                }
            }
        }
  
        # Convert to JSON Object.
        $body = $body | ConvertTo-Json
  
        # Refresh all Access Tokens.
        $this.RefreshAccessTokens()

        Write-Host `
            -Object 'Creating Purview Source for Synapse...'

        # Create Source for Synapse.
        $uri = "https://$($this.parameters.PurviewAccountName).purview.azure.com/scan/datasources/$($collectionNameSynapse)?api-version=2022-07-01-preview"
        Invoke-RestMethod `
            -Uri $uri `
            -Method PUT `
            -Body $body `
            -Headers @{ Authorization = "Bearer $($this.accessTokenPurview)" } `
            -ContentType 'application/json'
    }

    hidden SetSynapsePurviewIntegration() {
        Write-Host `
            -Object 'Obtaining Managed Identity ID for Purview Account...'
        $purviewAccountManagedIdentityId = ((az purview account show `
                    --name $this.parameters.PurviewAccountName `
                    --resource-group $this.parameters.ResourceGroupName) | ConvertFrom-Json).identity.principalId

        # Assign Storage BLOB Data Reader Permission to entire Resource Group.
        Write-Host `
            -Object 'Assigning Storage BLOB Data Reader Permission to Purview Account...'
        az role assignment create `
            --assignee-object-id $purviewAccountManagedIdentityId `
            --scope "/subscriptions/$($this.parameters.SubscriptionId)/resourceGroups/$($this.parameters.ResourceGroupName)" `
            --role '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

        # Assign Reader Permission to entire Resource Group.
        Write-Host `
            -Object 'Assigning Storage BLOB Data Reader Permission to Purview Account...'
        az role assignment create `
            --assignee-object-id $purviewAccountManagedIdentityId `
            --scope "/subscriptions/$($this.parameters.SubscriptionId)/resourceGroups/$($this.parameters.ResourceGroupName)" `
            --role Reader

        try {
            # Refresh Tokens to ensure we don't have a failure.
            $this.RefreshAccessTokens()

            # Create new Login for Purview in Synapse Serverless Pool.
            Write-Host `
                -Object 'Creating Login in Azure Synapse - Serverless Pool...'
            
            Invoke-Sqlcmd `
                -Query "CREATE LOGIN [$($this.parameters.PurviewAccountName)] FROM EXTERNAL PROVIDER;" `
                -ServerInstance "$($this.parameters.SynapseWorkspaceName)-ondemand.sql.azuresynapse.net" `
                -Database 'master' `
                -AccessToken $this.accessTokenDatabase

            # Create new Login for Purview in Synapse Dedicated Pool.
            Write-Host `
                -Object 'Creating Login in Azure Synapse - Dedicated Pool...'
            
            Invoke-Sqlcmd `
                -Query "CREATE LOGIN [$($this.parameters.PurviewAccountName)] FROM EXTERNAL PROVIDER;" `
                -ServerInstance "$($this.parameters.SynapseWorkspaceName)-ondemand.sql.azuresynapse.net" `
                -Database 'master' `
                -AccessToken $this.accessTokenDatabase
        }
        catch {
            Write-Host `
                -Object "An error occurred while creating Login for Purview in Synapse. Error Stack: $($_)"
        }
    }

    hidden RefreshAccessTokens() {
        $this.accessTokenSynapse = ((az account get-access-token --resource 'https://dev.azuresynapse.net' --output json) | ConvertFrom-Json).accessToken
        $this.accessTokenPurview = ((az account get-access-token --resource 'https://purview.azure.net' --output json) | ConvertFrom-Json).accessToken
        $this.accessTokenDatabase = ((az account get-access-token --resource 'https://database.windows.net' --output json) | ConvertFrom-Json).accessToken
    }
}

[DeploymentManager]$deployer = [DeploymentManager]::new()
$deployer.DeploymentProcessor(
    $resourceGroupName
    , $location
    , $storageAccountName
    , $synapseWorkspaceName
    , $synapseAdminUsername
    , $synapseAdminPassword
    , $synapseDedicatedPoolName
    , $synapseDedicatedPoolSize
    , $synapseAADAdministratorGuid
    , $purviewAccountName
    , $tagsSynapseWorkspace
    , $tagsSynapseDedicatedPool
    , $tagsPurviewAccount
)
