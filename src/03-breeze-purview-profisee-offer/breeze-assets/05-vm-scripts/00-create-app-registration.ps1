param (
    [Parameter(Mandatory = $true)][string]$externalDnsName
    , [Parameter(Mandatory = $true)][string]$appRegistrationClientName
)

class BreezeSetupUtils {
    static [string] RegisterApp([string]$externalDnsName, [string]$appRegistrationClientName) {
        Clear-Host

        # Create App Registration.
        $commandText = "az ad app create ``
        --display-name $($appRegistrationClientName) ``
        --enable-id-token-issuance ``
        --web-redirect-uris 'https://$($externalDnsName)/profisee/auth/signin-microsoft'"

        Write-Host 'Creating App Registration...'
        Invoke-Expression $commandText

        Write-Host 'Sleeping for 10 seconds for full-creation of App Registration...'
        Start-Sleep `
            -Seconds 10

        # Get Registered Application ID.
        $azureClientId = az ad app list `
            --filter "displayname eq '$appRegistrationClientName'" `
            --query '[0].appId'

        # Add a Graph API permission of "Sign in and read user profile".
        $commandText = "az ad app permission add ``
        --id $($azureClientId) ``
        --api 00000003-0000-0000-c000-000000000000 ``
        --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope"

        Write-Host 'Adding Graph Permission: User.Read...'
        Invoke-Expression $commandText

        # Creating Service Principal.
        $commandText = "az ad sp create ``
        --id $($azureClientId)"

        Write-Host 'Creating Service Principal...'
        Invoke-Expression $commandText

        # Grant Permission.
        $commandText = "az ad app permission grant ``
        --id $($azureClientId) ``
        --api 00000003-0000-0000-c000-000000000000 ``
        --scope User.Read"

        Write-Host 'Granting Permissions...'
        Invoke-Expression $commandText

        # Add Group Claims.
        $commandText = "az ad app update ``
        --id $($azureClientId) ``
        --set groupMembershipClaims=SecurityGroup ``
        --optional-claims '{`"idToken`":[{`"additionalProperties`":[],`"essential`":false,`"name`":`"groups`",`"source`":null}],`"accessToken`":[{`"additionalProperties`":[],`"essential`":false,`"name`":`"groups`",`"source`":null}],`"saml2Token`":[{`"additionalProperties`":[],`"essential`":false,`"name`":`"groups`",`"source`":null}]}'"

        Write-Host 'Adding Group Claims Configuration...'
        Invoke-Expression $commandText

        # Get Credential.
        $commandText = "az ad app credential reset ``
            --id $($azureClientId) ``
            --display-name 'profiseepassword'"
        $commandOutput = Invoke-Expression $commandText

        return $commandOutput
    }
}

$appSecret = [BreezeSetupUtils]::RegisterApp($externalDnsName, $appRegistrationClientName)
Write-Host $appSecret