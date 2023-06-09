class BreezeParameters {
    # There should be EXACTLY 1 Subscription ID available for going further.
    [string]$SubscriptionId

    # Provide a NEW Resource Group Name. For existing Resource Group, success may be diminished.
    [string]$ResourceGroupName

    # Provide a Azure Region code that should be used for the deployment.
    [string]$ResourcesLocation

    # Provide a list of all Tags in JSON string format that should be applied to the resources.
    [string]$ResourcesTags

    # Provide Storage account Name to be used.
    [string]$StorageAccountName

    # Provide Synapse Workspace Name to be used.
    [string]$SynapseWorkspaceName

    # Provide SKU code for Synapse Dedicated Pool.
    [string]$SynapseSqlPoolDedicatedSku

    # Provide Synapse Administrator Username.
    [string]$SynapseAdminUsername

    # Provide Synapse Administrator Password.
    [string]$SynapseAdminPassword

    # Provide Synapse Administrator User GUID from Azure AD.
    [string]$SynapseAdministratorUserGuid

    [string] ToStringParametersAll() {
        return "
Globals:
--------
Subscription ID                     : $($this.SubscriptionId)
Tags                                : $($this.ResourcesTags)
Location                            : $($this.ResourcesLocation)

Resources:
----------
Resource Group Name                 : $($this.ResourceGroupName)
Storage Account Name                : $($this.StorageAccountName)
Synapse Workspace Name              : $($this.SynapseWorkspaceName)
Synapse Dedicated Pool SKU          : $($this.SynapseSqlPoolDedicatedSku)
Synapse Administrator Username      : $($this.SynapseAdminUsername)
Synapse Administrator Password      : $($this.SynapseAdminPassword)
Synapse Azure AD Administrator GUID : $($this.SynapseAdministratorUserGuid)
"
    }

    [string] ToStringParametersSynapse() {
        return "
Resources:
----------
Synapse Workspace Name         : $($this.SynapseWorkspaceName)
Synapse Administrator Username : $($this.SynapseAdminUsername)
Synapse Administrator Password : $($this.SynapseAdminPassword)
"

    }
    
    [string] ToStringParametersResourceGroup() {
        return "
Resource Group to Delete : $($this.ResourceGroupName)
"
    }
}

class DeploymentManager {
    hidden [string]$accessTokenSynapse = ''
    hidden [BreezeParameters]$parameters = [BreezeParameters]::new()
    hidden [DateTime]$startedOn = (Get-Date)
    hidden [DateTime]$endedOn = (Get-Date)

    DeploymentProcessor() {
        Clear-Host
        Write-Host `
            -ForegroundColor Yellow `
            -NoNewline `
            -Object "
+----------------------------------------------+
|     Motifworks BREEZE Deployment Manager     |
+----------------------------------------------+

Please select one of the following:
1. Install BREEZE from Azure Storage Account and local machine combination.
2. Install BREEZE Synapse Assets ONLY - assuming you've forked from Azure Portal.
3. Delete Resource Group.

Your choice: "

        $userInputResponse = Read-Host

        if ($userInputResponse -eq 1) {
            $this.WelcomeBannerFullInstall()
            $this.LoginAndSetSubscription()
            $this.ReadParametersFullInstall()
            Clear-Host
            $this.startedOn = (Get-Date)
            $this.ShowParametersFullInstall()
            $this.StoreParameters()
            $this.CreateResourceGroup()
            $this.CreateResources()
            $this.PrepareAndUploadSynapseAssets()
            $this.endedOn = (Get-Date)
            $totalTime = $this.endedOn - $this.startedOn
            Write-Host "Total Time Taken: $($totalTime.Minutes) min $($totalTime.Seconds) sec"
        }
        elseif ($userInputResponse -eq 2) {
            $this.WelcomeBannerSynapseOnlyInstall()
            $this.LoginAndSetSubscription()
            $this.ReadSynapseWorkspaceAndCredentials()
            Clear-Host
            $this.startedOn = (Get-Date)
            $this.ShowParametersSynapseOnlyInstall()
            $this.PrepareAndUploadSynapseAssets()
            $this.endedOn = (Get-Date)
            $totalTime = $this.endedOn - $this.startedOn
            Write-Host "Total Time Taken: $($totalTime.Minutes) min $($totalTime.Seconds) sec"
        }
        elseif ($userInputResponse -eq 3) {
            $this.WelcomeBannerFullDestroy()
            $this.LoginAndSetSubscription()
            $this.ReadResourceGroupName()
            Clear-Host
            $this.startedOn = (Get-Date)
            $this.ShowParametersFullDestroy()
            $this.DeleteResourceGroup()
            $this.endedOn = (Get-Date)
            $totalTime = $this.endedOn - $this.startedOn
            Write-Host "Total Time Taken: $($totalTime.Minutes) min $($totalTime.Seconds) sec"
        }
        else {
            Write-Host `
                -ForegroundColor Red `
                -Object 'Option not recognized. Exiting... '

            exit
        }
    }

    hidden WelcomeBannerFullInstall() {
        Clear-Host

        Write-Host `
            -ForegroundColor Yellow `
            -Object "
Please READ this carefully before proceeding further if you are new to this PowerShell Script interface.

Subscription
------------
You need to have access to at least 1 Subscription before you proceed further. Please get it's Subscription ID as you'll need it.

Permissions
-----------
Kindly ensure that you've the right permissions available to fork resources.

Location
--------
Ensure that the location code you select has availability of intended resources. In this case, it'd be Synapse, Storage Account.

Tags
----
You need to provide this in JSON format. An Example when asked (without double quotes): `"{ `"Generator`": `"Motifworks BREEZE Data Framework`", `"Project`": `"BREEZE`" }`"

Resource Group Name
-------------------
Try to provide a NEW Resource Group Name. For existing resource group, success may be diminished.

Synapse Admin Username
----------------------
Ensure that you don't provide any known SQL Server Username. That'll cause failure.

Synapse Admin Password
----------------------
Should be a complex password. 

Synapse Azure AD Admin
----------------------
Your ID will be used and you'll be assigned as Administrator of Synapse Workspace as Azure AD User.

Press any key to continue to Azure Logon via CLI...
"
        Read-Host
    }

    hidden WelcomeBannerSynapseOnlyInstall() {
        Clear-Host

        Write-Host `
            -ForegroundColor Yellow `
            -Object "
Please READ this carefully before proceeding further if you are new to this PowerShell Script interface.

Synapse Details
---------------
You'll need following:
1. Synapse Workspace Name
2. Synapse Administrator Username - SQL User.
3. Synapse Administrator Password (of above SQL User).

Press any key to continue to Azure Logon via CLI...
"
        Read-Host
    }

    hidden WelcomeBannerFullDestroy() {
        Clear-Host

        Write-Host `
            -ForegroundColor Yellow `
            -Object "
Please READ this carefully before proceeding further if you are new to this PowerShell Script interface.

Resource Group Name
-------------------
All the needed resources should have been spinned through ARM Templates of BREEZE.
Any external / manual installations don't warranty success.
You should have total access for deleting resources on this Resource Group.

Press any key to continue to Azure Logon via CLI...
"
        Read-Host
    }

    hidden LoginAndSetSubscription() {
        # Perform Logon on Azure.
        az `
            login `
            --only-show-errors

        # Get list of all Subscriptions for logged in User.
        $subscriptions = az `
            account `
            subscription `
            list `
            --only-show-errors | ConvertFrom-Json

        # Set current User's ID as Synapse Administrator linked with Azure AD.
        $this.parameters.SynapseAdministratorUserGuid = (az ad signed-in-user show | ConvertFrom-Json).id

        if ($subscriptions.Count -gt 1) {
            # If there are multiple subscriptions, select one.
            Write-Host `
                -ForegroundColor Red `
                -Object "You've multiple subscriptions. You need to select exactly one."

            foreach ($currentSubscription in $subscriptions) {
                Write-Host `
                    -ForegroundColor Blue `
                    "Subscription ID: $($currentSubscription.subscriptionId)"
            }

            # Set 1st Subscription ID as default value.
            $defaultValue = $subscriptions[0].subscriptionId

            # Read Subscription ID from User.
            $userInputResponse = Read-Host `
                -Prompt "Subscription ID (default: [$($defaultValue)]): "

            # Assign Parameter value for Subscription ID.
            if ([string]::IsNullOrEmpty($userInputResponse)) {
                $this.parameters.SubscriptionId = $defaultValue
            }
            else {
                $this.parameters.SubscriptionId = [string]$userInputResponse
            }
        }
        elseif ($subscriptions.Count -eq 1) {
            # This is scenario of ONLY 1 Subscription. Pick-up default value and use it.
            $this.parameters.SubscriptionId = $subscriptions[0].subscriptionId
        }
        else {
            # This should NOT happen. If it happens, it means that there is NO subscription available. Error out and exit.
            Write-Host `
                -ForegroundColor Red `
                -Object 'There is no Subscription available. Exiting now...'

            exit
        }
    }

    hidden ReadResourceGroupName() {
        # Set default value for Resource Group Name.
        $defaultValue = 'rg-breeze-dev'

        # Read Resource Group Name from User.
        $userInputResponse = Read-Host `
            -Prompt "Resource Group Name (default: [$($defaultValue)])"

        # Assign Parameter value for Resource Group Name.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.ResourceGroupName = $defaultValue
        }
        else {
            $this.parameters.ResourceGroupName = [string]$userInputResponse
        }
    }

    hidden ReadSynapseWorkspaceAndCredentials() {
        # Set default value for Synapse Workspace Name.
        $defaultValue = 'synw-breeze-dev'

        # Read Synapse Workspace Name from User.
        $userInputResponse = Read-Host `
            -Prompt "Synapse Workspace Name (default: [$($defaultValue)])"

        # Assign Parameter value for Synapse Workspace Name.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.SynapseWorkspaceName = $defaultValue
        }
        else {
            $this.parameters.SynapseWorkspaceName = [string]$userInputResponse
        }

        # Set default value for Synapse Administrator Username.
        $defaultValue = 'breezeadmin'

        # Read Synapse Administrator Username.
        $userInputResponse = Read-Host `
            -Prompt "Synapse Administrator Username (default: [$($defaultValue)])"

        # Assign Parameter value for Synapse Administrator Username.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.SynapseAdminUsername = $defaultValue
        }
        else {
            $this.parameters.SynapseAdminUsername = [string]$userInputResponse
        }

        # Set default value for Synapse Administrator Password.
        $defaultValue = 'Smoothie@2023'

        # Read Synapse Administrator Password.
        $userInputResponse = Read-Host `
            -Prompt "Synapse Administrator Password (default: [$($defaultValue)])"
        
        # Assign Parameter value for Synapse Administrator Password.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.SynapseAdminPassword = $defaultValue
        }
        else {
            $this.parameters.SynapseAdminPassword = [string]$userInputResponse
        }
    }

    hidden ReadParametersFullInstall() {
        # Set default value for Tags JSON Object.
        $defaultValue = '{"Generator": "Motifworks BREEZE Data Framework", "Project": "BREEZE"}'

        # Read Tags JSON Object from User.
        $userInputResponse = Read-Host `
            -Prompt "Tags (default: [$($defaultValue)])"

        # Assign Parameter value for Tags JSON String.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.ResourcesTags = $defaultValue
        }
        else {
            $this.parameters.ResourcesTags = [string]$userInputResponse
        }

        # Set default value for Location.
        $defaultValue = 'eastus2'

        # Read Location Name from User.
        $userInputResponse = Read-Host `
            -Prompt "Location (default: [$($defaultValue)])"

        # Assign Parameter value for Location.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.ResourcesLocation = $defaultValue
        }
        else {
            $this.parameters.ResourcesLocation = [string]$userInputResponse
        }

        # Use existing function.
        $this.ReadResourceGroupName()

        # Set default value for Storage Account Name.
        $defaultValue = 'stmwbreezedev'

        # Read Storage Account Name from User.
        $userInputResponse = Read-Host `
            -Prompt "Storage Account Name (default: [$($defaultValue)])"

        # Assign Parameter value for Storage Account Name.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.StorageAccountName = $defaultValue
        }
        else {
            $this.parameters.StorageAccountName = [string]$userInputResponse
        }

        # Use existing function to read core Synapse parameters.
        $this.ReadSynapseWorkspaceAndCredentials()

        # Set default value for Synapse Dedicated Pool SKU.
        $defaultValue = 'DW100c'

        # Read Synapse Dedicated Pool SKU from User.
        $userInputResponse = Read-Host `
            -Prompt "Synapse Dedicated Pool SKU (default: [$($defaultValue)])"

        # Assign Parameter value for Synapse Dedicated Pool SKU.
        if ([string]::IsNullOrEmpty($userInputResponse)) {
            $this.parameters.SynapseSqlPoolDedicatedSku = $defaultValue
        }
        else {
            $this.parameters.SynapseSqlPoolDedicatedSku = [string]$userInputResponse
        }
    }

    hidden ShowParametersFullInstall() {
        # Show all provided values.
        Write-Host `
            -ForegroundColor Green `
            "Provided Values: 
            $($this.parameters.ToStringParametersAll())"
    }

    hidden ShowParametersSynapseOnlyInstall() {
        # Show all provided values.
        Write-Host `
            -ForegroundColor Green `
            "Provided Values: 
            $($this.parameters.ToStringParametersSynapse())"
    }

    hidden ShowParametersFullDestroy() {
        # Show all provided values.
        Write-Host `
            -ForegroundColor Red `
            "Provided Values for Deletion: 
            $($this.parameters.ToStringParametersResourceGroup())"
    }
    
    hidden StoreParameters () {
        # Duplicate and overwrite(if needed) the template Parameters file.
        Copy-Item `
            -Path '.\mainTemplate.parameters.template.json' `
            -Destination '.\mainTemplate.parameters.json'

        # Read file contents into variable.
        $fileContents = Get-Content `
            -Raw `
            -Path '.\mainTemplate.parameters.json'

        # Perform Replacements.
        $fileContents = $fileContents.Replace('{{LOCATION}}', $this.parameters.ResourcesLocation)
        $fileContents = $fileContents.Replace('{{TAGS}}', $this.parameters.ResourcesTags)
        $fileContents = $fileContents.Replace('{{STORAGE_ACCOUNT_NAME}}', $this.parameters.StorageAccountName)
        $fileContents = $fileContents.Replace('{{SYNAPSE_WORKSPACE_NAME}}', $this.parameters.SynapseWorkspaceName)
        $fileContents = $fileContents.Replace('{{SYNAPSE_DEDICATED_POOL_SKU}}', $this.parameters.SynapseSqlPoolDedicatedSku)
        $fileContents = $fileContents.Replace('{{SYNAPSE_ADMIN_USERNAME}}', $this.parameters.SynapseAdminUsername)
        $fileContents = $fileContents.Replace('{{SYNAPSE_ADMIN_PASSWORD}}', $this.parameters.SynapseAdminPassword)
        $fileContents = $fileContents.Replace('{{SYNAPSE_ADMIN_AAD_GUID}}', $this.parameters.SynapseAdministratorUserGuid)

        # Update File Contents.
        Set-Content `
            -Path '.\mainTemplate.parameters.json' `
            -Value $fileContents
    }

    hidden RefreshAccessTokens() {
        $this.accessTokenSynapse = ((az account get-access-token --resource 'https://dev.azuresynapse.net' --output json) | ConvertFrom-Json).accessToken
    }

    hidden [string] GetTags() {
        $returnValue = ''

        $($this.parameters.ResourcesTags | ConvertFrom-Json).PSObject.Properties | ForEach-Object { 
            $returnValue = $returnValue + "$($_.Name)='$($_.Value)' "
        } 

        return $returnValue
    }

    hidden CreateResourceGroup() {
        $commandText = "
        az ``
            group ``
            create ``
            --location $($this.parameters.ResourcesLocation) ``
            --name $($this.parameters.ResourceGroupName) ``
            --tags $($this.GetTags())"

        Invoke-Expression $commandText
    }

    hidden CreateResources() {
        az deployment group create `
            --resource-group $this.parameters.ResourceGroupName `
            --name "breeze-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')" `
            --parameters mainTemplate.parameters.json `
            --template-file mainTemplate.json
    }

    hidden PrepareAndUploadSynapseAssets() {
        # Create strings that are used in replacments in Datasets and Pipelines.
        $defaultLinkedServiceNameSynapse = "$($this.parameters.SynapseWorkspaceName)-WorkspaceDefaultSqlServer"
        $defaultLinkedServiceNameStorage = "$($this.parameters.SynapseWorkspaceName)-WorkspaceDefaultStorage"

        Write-Host `
            -ForegroundColor Blue `
            -Object '
Creating Tables in Azure Synapse...' `
            
        SqlCmd `
            -I `
            -i './breeze-assets/01-sql-scripts/breeze-ddl.sql' `
            -S "$($this.parameters.SynapseWorkspaceName).sql.azuresynapse.net" `
            -d 'syndpbreeze' `
            -U $this.parameters.SynapseAdminUsername `
            -P $this.parameters.SynapseAdminPassword

        # This is necessary as Tokens expire much frequently.
        $this.RefreshAccessTokens()

        # Creating Azure Synapse Datasets.
        Write-Host `
            -ForegroundColor Blue `
            -Object '
Creating Datasets in Azure Synapse...'

        # Get list of all Datasets from Local Computer.
        $datasets = Get-ChildItem './breeze-assets/02-datasets' | Select-Object BaseName

        # Iterate over Datasets and create each separately.
        foreach ($currentDataset in $datasets) {
            try {
                Write-Host `
                    -ForegroundColor Yellow `
                    -Object "Creating Dataset: $($currentDataset.BaseName)"

                # Read all file contents.
                $fileContents = Get-Content `
                    -Raw `
                    -Path "./breeze-assets/02-datasets/$($currentDataset.BaseName).json"

                # Perform Replacements.
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_SYNAPSE}}', $defaultLinkedServiceNameSynapse)
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_STORAGE}}', $defaultLinkedServiceNameStorage)

                # Create Dataset on Azure Synapse.
                Invoke-RestMethod `
                    -Uri "https://$($this.parameters.SynapseWorkspaceName).dev.azuresynapse.net/datasets/$($currentDataset.BaseName)?api-version=2021-06-01" `
                    -Method PUT `
                    -Body $fileContents `
                    -Headers @{ Authorization = "Bearer $($this.accessTokenSynapse)" } `
                    -ContentType 'application/json'
            }
            catch {
                Write-Host `
                    -ForegroundColor Red `
                    -Object "An error occurred while publishing Dataset: $($currentDataset.BaseName). Error Stack: $($_)"
            }
        }

        # This is necessary as Tokens expire much frequently.
        $this.RefreshAccessTokens()

        # Creating Azure Synapse Notebooks.
        Write-Host `
            -ForegroundColor Blue `
            -Object '
Creating Notebooks in Azure Synapse...'

        # Get list of all Notebooks from Local Computer.
        $notebooks = Get-ChildItem './breeze-assets/03-notebooks' | Select-Object BaseName

        # Iterate over Notebooks and create each separately.
        foreach ($currentNotebook in $notebooks) {
            try {
                Write-Host `
                    -ForegroundColor Yellow `
                    -Object "Creating Notebook: $($currentNotebook.BaseName)"

                # Read all file contents.
                $fileContents = Get-Content `
                    -Raw `
                    -Path "./breeze-assets/03-notebooks/$($currentNotebook.BaseName).ipynb"

                # Perform Replacements.
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_SYNAPSE}}', $defaultLinkedServiceNameSynapse)
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_STORAGE}}', $defaultLinkedServiceNameStorage)
                $fileContents = $fileContents.Replace('{{SYNPAPSE_WORKSPACE_NAME}}', $this.parameters.SynapseWorkspaceName)
                $fileContents = $fileContents.Replace('{{BREEZE_ADMIN_USERNAME}}', $this.parameters.SynapseAdminUsername)
                $fileContents = $fileContents.Replace('{{BREEZE_ADMIN_PASSWORD}}', $this.parameters.SynapseAdminPassword)

                # Create Notebook on Azure Synapse.
                Invoke-RestMethod `
                    -Uri "https://$($this.parameters.SynapseWorkspaceName).dev.azuresynapse.net/notebooks/$($currentNotebook.BaseName)?api-version=2021-06-01" `
                    -Method PUT `
                    -Body $fileContents `
                    -Headers @{ Authorization = "Bearer $($this.accessTokenSynapse)" } `
                    -ContentType 'application/json'
            }
            catch {
                Write-Host `
                    -ForegroundColor Red `
                    -Object "An error occurred while publishing Notebook: $($currentNotebook.BaseName). Error Stack: $($_)"
            }
        }

        # This is necessary as Tokens expire much frequently.
        $this.RefreshAccessTokens()

        # Creating Azure Synapse Pipelines.
        Write-Host `
            -ForegroundColor Blue `
            -Object '
Creating Pipelines in Azure Synapse...'

        # Get list of all Pipelines from Local Computer.
        $pipelines = Get-ChildItem './breeze-assets/04-pipelines' | Select-Object BaseName

        # Iterate over Pipelines and create each separately.
        foreach ($currentPipeline in $pipelines) {
            try {
                Write-Host `
                    -ForegroundColor Yellow `
                    "Creating Pipeline: $($currentPipeline.BaseName)"

                # Read all file contents.
                $fileContents = Get-Content `
                    -Raw `
                    -Path "./breeze-assets/04-pipelines/$($currentPipeline.BaseName).json"

                # Perform Replacements.
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_SYNAPSE}}', $defaultLinkedServiceNameSynapse)
                $fileContents = $fileContents.Replace('{{DEFAULT_LINKED_SERVICE_NAME_STORAGE}}', $defaultLinkedServiceNameStorage)

                # Create Pipeline on Azure Synapse.
                Invoke-RestMethod `
                    -Uri "https://$($this.parameters.SynapseWorkspaceName).dev.azuresynapse.net/pipelines/$($currentPipeline.BaseName)?api-version=2021-06-01" `
                    -Method PUT `
                    -Body $fileContents `
                    -Headers @{ Authorization = "Bearer $($this.accessTokenSynapse)" } `
                    -ContentType 'application/json'
            }
            catch {
                Write-Host `
                    -ForegroundColor Red `
                    -Object "An error occurred while publishing Pipeline: $($currentPipeline.BaseName). Error Stack: $($_)"
            }
        }
    }

    hidden DeleteResourceGroup() {
        az `
            group `
            delete `
            --yes `
            --name $($this.parameters.ResourceGroupName)
    }
}

[DeploymentManager]$deployer = [DeploymentManager]::new()
$deployer.DeploymentProcessor()
