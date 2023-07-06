#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
logfile=log_$(date +%Y-%m-%d_%H-%M-%S).out
exec 1>$logfile 2>&1

#Installation of Key Vault Container Storage Interface (CSI) driver started.
if [ "$USEKEYVAULT" = "Yes" ]; then
    #Assign AAD roles to the AKS AgentPool Managed Identity. The Pod identity communicates with the AgentPool MI, which in turn communicates with the Key Vault specific Managed Identity.
    echo $"AKS Managed Identity configuration for Key Vault access started."

    echo $"AKS AgentPool Managed Identity configuration for Key Vault access step 1 started."
    echo "Running az role assignment create --role "Managed Identity Operator" --assignee-object-id $KUBERNETESOBJECTID --assignee-principal-type ServicePrincipal --scope /subscriptions/$SUBSCRIPTIONID/resourcegroups/$RESOURCEGROUPNAME"
    az role assignment create --role "Managed Identity Operator" --assignee-object-id $KUBERNETESOBJECTID --assignee-principal-type ServicePrincipal --scope /subscriptions/$SUBSCRIPTIONID/resourcegroups/$RESOURCEGROUPNAME
    echo "Running az role assignment create --role "Managed Identity Operator" --assignee-object-id $KUBERNETESOBJECTID --assignee-principal-type ServicePrincipal --scope /subscriptions/$SUBSCRIPTIONID/resourcegroups/$AKSINFRARESOURCEGROUPNAME"
    az role assignment create --role "Managed Identity Operator" --assignee-object-id $KUBERNETESOBJECTID --assignee-principal-type ServicePrincipal --scope /subscriptions/$SUBSCRIPTIONID/resourcegroups/$AKSINFRARESOURCEGROUPNAME
    echo "Running az role assignment create --role "Virtual Machine Contributor" --assignee-object-id $KUBERNETESOBJECTID --assignee-principal-type ServicePrincipal --scope /subscriptions/$SUBSCRIPTIONID/resourcegroups/$AKSINFRARESOURCEGROUPNAME"
    az role assignment create --role "Virtual Machine Contributor" --assignee-object-id $KUBERNETESOBJECTID --assignee-principal-type ServicePrincipal --scope /subscriptions/$SUBSCRIPTIONID/resourcegroups/$AKSINFRARESOURCEGROUPNAME
    echo $"AKS AgentPool Managed Identity configuration for Key Vault access step 1 finished."

    #Create Azure AD Managed Identity specifically for Key Vault, get its ClientiId and PrincipalId so we can assign to it the Reader role in steps 3a, 3b and 3c to.
    echo $"Key Vault Specific Managed Identity configuration for Key Vault access step 2 started."
    identityName="AKSKeyVaultUser"
    akskvidentityClientId=$(az identity create -g $AKSINFRARESOURCEGROUPNAME -n $identityName --query 'clientId' -o tsv)
    akskvidentityClientResourceId=$(az identity show -g $AKSINFRARESOURCEGROUPNAME -n $identityName --query 'id' -o tsv)
    principalId=$(az identity show -g $AKSINFRARESOURCEGROUPNAME -n $identityName --query 'principalId' -o tsv)
    echo $"Key VAult Specific Managed Identity configuration for Key Vault access step 2 finished."

    echo $"Key Vault Specific Managed Identity configuration for KV access step 3 started."
    echo "Sleeping for 60 seconds to wait for MI to be ready"
    sleep 60
    #KEYVAULT looks like this this /subscriptions/$SUBID/resourceGroups/$kvresourceGroup/providers/Microsoft.KeyVault/vaults/$kvname
    IFS='/' read -r -a kv <<<"$KEYVAULT" #splits the KEYVAULT on slashes and gets last one
    keyVaultName=${kv[-1]}
    keyVaultResourceGroup=${kv[4]}
    keyVaultSubscriptionId=${kv[2]}
    echo $"KEYVAULT is $KEYVAULT"
    echo $"keyVaultName is $keyVaultName"
    echo $"akskvidentityClientId is $akskvidentityClientId"
    echo $"principalId is $principalId"

    #Check if Key Vault is RBAC or policy based.
    echo $"Checking if Key Vauls is RBAC based or policy based"
    rbacEnabled=$(az keyvault show --name $keyVaultName --subscription $keyVaultSubscriptionId --query "properties.enableRbacAuthorization")

    #If Key Vault is RBAC based, assign Key Vault Secrets User role to the Key Vault Specific Managed Identity, otherwise assign Get policies for Keys, Secrets and Certificates.
    if [ "$rbacEnabled" = true ]; then
        echo $"Setting Key Vault Secrets User RBAC role to the Key Vault Specific Managed Identity."
        echo "Running az role assignment create --role 'Key Vault Secrets User' --assignee $principalId --scope $KEYVAULT"
        az role assignment create --role "Key Vault Secrets User" --assignee $principalId --scope $KEYVAULT
    else
        echo $"Setting Key Vault access policies to the Key Vault Specific Managed Identity."
        echo $"Key Vault Specific Managed Identity configuration for KV access step 3a started. Assigning Get access policy for secrets."
        echo "Running az keyvault set-policy -n $keyVaultName --subscription $keyVaultSubscriptionId --secret-permissions get --object-id $principalId --query id"
        az keyvault set-policy -n $keyVaultName --subscription $keyVaultSubscriptionId --secret-permissions get --object-id $principalId --query id
        echo $"Key Vault Specific Managed Identity configuration for KV access step 3a finished. Assignment completed."

        echo $"Key Vault Specific Managed Identity configuration for KV access step 3b started. Assigning Get access policy for keys."
        echo "Running az keyvault set-policy -n $keyVaultName --subscription $keyVaultSubscriptionId --key-permissions get --object-id $principalId --query id"
        az keyvault set-policy -n $keyVaultName --subscription $keyVaultSubscriptionId --key-permissions get --object-id $principalId --query id
        echo $"Key Vault Specific Managed Identity configuration for KV access step 3b finished. Assignment completed."

        echo $"Key Vault Specific Managed Identity configuration for KV access step 3c started. Assigning Get access policy for certificates."
        echo "Running az keyvault set-policy -n $keyVaultName --subscription $keyVaultSubscriptionId --certificate-permissions get --object-id $principalId --query id"
        az keyvault set-policy -n $keyVaultName --subscription $keyVaultSubscriptionId --certificate-permissions get --object-id $principalId --query id
        echo $"Key Vault Specific Managed Identity configuration for KV access step 3c finished. Assignment completed."

        echo $"Key Vault Specific Managed Identity setup is now finished."
    fi

fi

#Installation of Profisee platform
echo $"Installation of Profisee platform statrted."
#Configure Profisee helm chart settings
auth="$(echo -n "$ACRUSER:$ACRUSERPASSWORD" | base64 -w0)"
sed -i -e 's/$ACRUSER/'"$ACRUSER"'/g' Settings.yaml
sed -i -e 's/$ACRPASSWORD/'"$ACRUSERPASSWORD"'/g' Settings.yaml
sed -i -e 's/$ACREMAIL/'"support@profisee.com"'/g' Settings.yaml
sed -i -e 's/$ACRAUTH/'"$auth"'/g' Settings.yaml
sed -e '/$TLSCERT/ {' -e 'r tls.cert' -e 'd' -e '}' -i Settings.yaml
sed -e '/$TLSKEY/ {' -e 'r tls.key' -e 'd' -e '}' -i Settings.yaml

rm -f tls.cert
rm -f tls.key

echo $"WEBAPPNAME is $WEBAPPNAME"
WEBAPPNAME="${WEBAPPNAME,,}"
echo $"WEBAPPNAME is now lower $WEBAPPNAME"

#Acquire the collection id from the collection name
if [ "$USEPURVIEW" = "Yes" ]; then
    echo "Obtain collection id from provided collection friendly name started."
    echo "Grab a token."
    purviewtoken=$(curl --location --no-progress-meter --request GET "https://login.microsoftonline.com/$TENANTID/oauth2/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "client_id=$PURVIEWCLIENTID" --data-urlencode "client_secret=$PURVIEWCLIENTSECRET" --data-urlencode 'grant_type=client_credentials' --data-urlencode 'resource=https://purview.azure.net' | jq --raw-output '.access_token')
    echo "Token acquired."
    echo "Find collection Id."
    echo $"Stripping /catalog from $PURVIEWURL."
    PURVIEWACCOUNTFQDN=${PURVIEWURL::-8}
    echo $"Purview account name is $PURVIEWACCOUNTFQDN. Using it."
    COLLECTIONTRUEID=$(curl --location --no-progress-meter --request GET "$PURVIEWACCOUNTFQDN/account/collections?api-version=2019-11-01-preview" --header "Authorization: Bearer $purviewtoken" | jq --raw-output '.value | .[] | select(.friendlyName=="'$PURVIEWCOLLECTIONID'") | .name')
    echo $"Collection id is $COLLECTIONTRUEID, using that."
    echo "Obtain collection id from provided collection friendly name completed."
fi

echo "The variables will now be set in the Settings.yaml file"
#Setting storage related variables
FILEREPOUSERNAME="Azure\\\\\\\\${STORAGEACCOUNTNAME}"
FILEREPOURL="\\\\\\\\\\\\\\\\${STORAGEACCOUNTNAME}.file.core.windows.net\\\\\\\\${STORAGEACCOUNTFILESHARENAME}"

#PROFISEEVERSION looks like this profiseeplatform:2023R1.0
#The repository name is profiseeplatform, it is everything to the left of the colon sign :
#The label is everything to the right of the :

IFS=':' read -r -a repostring <<<"$PROFISEEVERSION"

#lowercase is the ,,
ACRREPONAME="${repostring[0],,}"
ACRREPOLABEL="${repostring[1],,}"

#Setting values in the Settings.yaml
sed -i -e 's/$SQLNAME/'"$SQLNAME"'/g' Settings.yaml
sed -i -e 's/$SQLDBNAME/'"$SQLDBNAME"'/g' Settings.yaml
sed -i -e 's/$SQLUSERNAME/'"$SQLUSERNAME"'/g' Settings.yaml
sed -i -e 's/$SQLUSERPASSWORD/'"$SQLUSERPASSWORD"'/g' Settings.yaml
sed -i -e 's/$FILEREPOACCOUNTNAME/'"$STORAGEACCOUNTNAME"'/g' Settings.yaml
sed -i -e 's/$FILEREPOUSERNAME/'"$FILEREPOUSERNAME"'/g' Settings.yaml
sed -i -e 's~$FILEREPOPASSWORD~'"$FILEREPOPASSWORD"'~g' Settings.yaml
sed -i -e 's/$FILEREPOURL/'"$FILEREPOURL"'/g' Settings.yaml
sed -i -e 's/$FILEREPOSHARENAME/'"$STORAGEACCOUNTFILESHARENAME"'/g' Settings.yaml
sed -i -e 's~$OIDCURL~'"$OIDCURL"'~g' Settings.yaml
sed -i -e 's/$CLIENTID/'"$CLIENTID"'/g' Settings.yaml
sed -i -e 's/$OIDCCLIENTSECRET/'"$OIDCCLIENTSECRET"'/g' Settings.yaml
sed -i -e 's/$ADMINACCOUNTNAME/'"$ADMINACCOUNTNAME"'/g' Settings.yaml
sed -i -e 's~$EXTERNALDNSURL~'"$EXTERNALDNSURL"'~g' Settings.yaml
sed -i -e 's/$EXTERNALDNSNAME/'"$EXTERNALDNSNAME"'/g' Settings.yaml
sed -i -e 's~$LICENSEDATA~'"$LICENSEDATA"'~g' Settings.yaml
sed -i -e 's/$ACRREPONAME/'"$ACRREPONAME"'/g' Settings.yaml
sed -i -e 's/$ACRREPOLABEL/'"$ACRREPOLABEL"'/g' Settings.yaml
sed -i -e 's~$PURVIEWURL~'"$PURVIEWURL"'~g' Settings.yaml
sed -i -e 's/$PURVIEWTENANTID/'"$TENANTID"'/g' Settings.yaml
sed -i -e 's/$PURVIEWCOLLECTIONID/'"$COLLECTIONTRUEID"'/g' Settings.yaml
sed -i -e 's/$PURVIEWCLIENTID/'"$PURVIEWCLIENTID"'/g' Settings.yaml
sed -i -e 's/$PURVIEWCLIENTSECRET/'"$PURVIEWCLIENTSECRET"'/g' Settings.yaml
sed -i -e 's/$WEBAPPNAME/'"$WEBAPPNAME"'/g' Settings.yaml
if [ "$USEKEYVAULT" = "Yes" ]; then
    sed -i -e 's/$USEKEYVAULT/'true'/g' Settings.yaml

    sed -i -e 's/$KEYVAULTIDENTITCLIENTID/'"$akskvidentityClientId"'/g' Settings.yaml
    sed -i -e 's~$KEYVAULTIDENTITYRESOURCEID~'"$akskvidentityClientResourceId"'~g' Settings.yaml

    sed -i -e 's/$SQL_USERNAMESECRET/'"$SQLUSERNAME"'/g' Settings.yaml
    sed -i -e 's/$SQL_USERPASSWORDSECRET/'"$SQLUSERPASSWORD"'/g' Settings.yaml
    sed -i -e 's/$TLS_CERTSECRET/'"$TLSCERT"'/g' Settings.yaml
    sed -i -e 's/$LICENSE_DATASECRET/'"$LICENSEDATASECRETNAME"'/g' Settings.yaml
    sed -i -e 's/$KUBERNETESCLIENTID/'"$KUBERNETESCLIENTID"'/g' Settings.yaml

    sed -i -e 's/$KEYVAULTNAME/'"$keyVaultName"'/g' Settings.yaml
    sed -i -e 's/$KEYVAULTRESOURCEGROUP/'"$keyVaultResourceGroup"'/g' Settings.yaml

    sed -i -e 's/$AZURESUBSCRIPTIONID/'"$keyVaultSubscriptionId"'/g' Settings.yaml
    sed -i -e 's/$AZURETENANTID/'"$TENANTID"'/g' Settings.yaml

else
    sed -i -e 's/$USEKEYVAULT/'false'/g' Settings.yaml
fi

sed -i -e 's/$USELETSENCRYPT/'false'/g' Settings.yaml

#Adding Settings.yaml as a secret generated only from the initial deployment of Profisee. Future updates, such as license changes via the profisee-license secret, or SQL credentials updates via the profisee-sql-password secret, will NOT be reflected in this secret. Proceed with caution!
kubectl delete secret profisee-settings -n profisee --ignore-not-found
kubectl create secret generic profisee-settings -n profisee --from-file=Settings.yaml

#################################Install Profisee Start #######################################
echo "Installation of Profisee platform started $(date +"%Y-%m-%d %T")"

#If Profisee is present, uninstall it. If not, proceeed to installation.
echo "If profisee is installed, uninstall it first."
profiseepresent=$(helm list -n profisee -f profiseeplatform -o table --short)
if [ "$profiseepresent" = "profiseeplatform" ]; then
    helm -n profisee uninstall profiseeplatform
    echo "Will sleep for 30 seconds to allow clean uninstall."
    sleep 30
fi
echo "Profisee is not installed, proceeding to install it."
helm -n profisee install profiseeplatform profisee/profisee-platform --values Settings.yaml

kubectl delete secret profisee-deploymentlog -n profisee --ignore-not-found
kubectl create secret generic profisee-deploymentlog -n profisee --from-file=$logfile

#Make sure it installed, if not return error
profiseeinstalledname=$(echo $(helm list --filter 'profisee+' -n profisee -o json) | jq '.[].name')
if [ -z "$profiseeinstalledname" ]; then
    echo "Profisee did not get installed. Exiting with error"
    exit 1
else
    echo "Installation of Profisee finished $(date +"%Y-%m-%d %T")"
fi
#################################Install Profisee End #######################################

#Wait for pod to be ready (downloaded)
echo "Waiting for pod to be downloaded and be ready..$(date +"%Y-%m-%d %T")"
sleep 30
kubectl wait --timeout=1800s --for=condition=ready pod/profisee-0 -n profisee

echo $"Profisee deploymented finished $(date +"%Y-%m-%d %T")"

result="{\"Result\":[\
{\"IP\":\"$nginxip\"},\
{\"WEBURL\":\"${EXTERNALDNSURL}/${WEBAPPNAME}\"},\
{\"FILEREPOUSERNAME\":\"$FILEREPOUSERNAME\"},\
{\"FILEREPOURL\":\"$FILEREPOURL\"},\
{\"AZUREAPPCLIENTID\":\"$CLIENTID\"},\
{\"AZUREAPPREPLYURL\":\"$azureAppReplyUrl\"},\
{\"SQLSERVER\":\"$SQLNAME\"},\
{\"SQLDATABASE\":\"$SQLDBNAME\"},\
{\"ACRREPONAME\":\"$ACRREPONAME\"},\
{\"ACRREPOLABEL\":\"$ACRREPOLABEL\"}\
]}"

echo $result

kubectl delete secret profisee-deploymentlog -n profisee --ignore-not-found
kubectl create secret generic profisee-deploymentlog -n profisee --from-file=$logfile

echo $result >$AZ_SCRIPTS_OUTPUT_PATH
