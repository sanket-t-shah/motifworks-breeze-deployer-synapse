param (
    [Parameter(Mandatory = $false)][string]$synapseWorkspaceName,
    [Parameter(Mandatory = $false)][string]$synapseAdminUsername,
    [Parameter(Mandatory = $false)][string]$synapseAdminPassword
)
class BreezeParameters {
    # There should be EXACTLY 1 Subscription ID available for going further.
    [string]$SubscriptionId

    # Provide Synapse Workspace Name to be used.
    [string]$SynapseWorkspaceName

    # Provide Synapse Administrator Username.
    [string]$SynapseAdminUsername

    # Provide Synapse Administrator Password.
    [string]$SynapseAdminPassword

    # Provide Synapse Administrator User GUID from Azure AD.
    [string]$SynapseAdministratorUserGuid

    [string] ToStringParametersSynapse() {
        return "
Resources:
----------
Subscription ID                : $($this.SubscriptionId)
Synapse Workspace Name         : $($this.SynapseWorkspaceName)
Synapse Administrator Username : $($this.SynapseAdminUsername)
Synapse Administrator Password : $($this.SynapseAdminPassword)
Synapse Administrator GUID     : $($this.SynapseAdministratorUserGuid)
"

    }
}

class DeploymentManager {
    hidden [string]$accessTokenSynapse = ''
    hidden [BreezeParameters]$parameters = [BreezeParameters]::new()
    hidden [DateTime]$startedOn = (Get-Date)
    hidden [DateTime]$endedOn = (Get-Date)

    DeploymentProcessor([string]$synapseWorkspaceName, [string]$synapseAdminUsername, [string]$synapseAdminPassword) {
        Write-Host `
            -ForegroundColor Yellow `
            -NoNewline `
            -Object '
+-------------------------------------------+
|     Motifworks BREEZE Assets Deployer     |
+-------------------------------------------+
'

        $this.LoginAndSetSubscription()
        $this.ReadSynapseWorkspaceAndCredentials()
        Clear-Host
        $this.startedOn = (Get-Date)
        $this.parameters.SynapseWorkspaceName = $synapseWorkspaceName
        $this.parameters.SynapseAdminUsername = $synapseAdminUsername
        $this.parameters.SynapseAdminPassword = $synapseAdminPassword
        $this.ShowParametersSynapseOnlyInstall()
        $this.PrepareAndUploadSynapseAssets()
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

        # Set current User's ID as Synapse Administrator linked with Azure AD.
        $this.parameters.SynapseAdministratorUserGuid = (az ad signed-in-user show | ConvertFrom-Json).id

        # This is scenario of ONLY 1 Subscription. Pick-up default value and use it.
        $this.parameters.SubscriptionId = $subscriptions[0].subscriptionId
    }

    hidden ShowParametersSynapseOnlyInstall() {
        # Show all provided values.
        Write-Host `
            -ForegroundColor Green `
            "Provided Values: 
            $($this.parameters.ToStringParametersSynapse())"
    }

    hidden RefreshAccessTokens() {
        $this.accessTokenSynapse = ((az account get-access-token --resource 'https://dev.azuresynapse.net' --output json) | ConvertFrom-Json).accessToken
    }

    hidden PrepareAndUploadSynapseAssets() {
        # Create strings that are used in replacments in Datasets and Pipelines.
        $defaultLinkedServiceNameSynapse = "$($this.parameters.SynapseWorkspaceName)-WorkspaceDefaultSqlServer"
        $defaultLinkedServiceNameStorage = "$($this.parameters.SynapseWorkspaceName)-WorkspaceDefaultStorage"

        try {
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
        }
        catch {
            Write-Host `
                -ForegroundColor Red `
                -Object "An error occurred while creating DB Objects (Table and Stored Procedures) in Synapse. Error Stack: $($_)"
        }

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
}

[DeploymentManager]$deployer = [DeploymentManager]::new()
$deployer.DeploymentProcessor($synapseWorkspaceName, $synapseAdminUsername, $synapseAdminPassword)
