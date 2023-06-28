#/bin/bash -e
echo $@
while getopts "a:b:c:d:e:f:g:h:i:j:k:l:m:" opt; do
    case $opt in
		a)
			resourceGroupName=$OPTARG
		;;
		b)
			location=$OPTARG
		;;
		c)
			storageAccountName=$OPTARG
		;;
		d)
			synapseWorkspaceName=$OPTARG
		;;
		e)
			synapseAdminUsername=$OPTARG
		;;
		f)
			synapseAdminPassword=$OPTARG
		;;
		g)
			synapseDedicatedPoolName=$OPTARG
		;;
		h)
			synapseDedicatedPoolSize=$OPTARG
		;;
		i)
			synapseAADAdministratorGuid=$OPTARG
		;;
		j)
			purviewAccountName=$OPTARG
		;;
		k)
			tagsSynapseWorkspace=$OPTARG
		;;
		l)
			tagsSynapseDedicatedPool=$OPTARG
		;;
		m)
			tagsPurviewAccount=$OPTARG
		;;
    esac
done
echo "................................................................................"
echo "Currently into Directory..."
echo `pwd`
echo "................................................................................"
echo "Calling PowerShell script..."
echo "sudo pwsh -Command ./02-deployment-executor.ps1 
	-resourceGroupName $resourceGroupName
	-location $location
	-storageAccountName $storageAccountName
	-synapseWorkspaceName $synapseWorkspaceName
	-synapseAdminUsername $synapseAdminUsername
	-synapseAdminPassword $synapseAdminPassword
	-synapseDedicatedPoolName $synapseDedicatedPoolName
	-synapseDedicatedPoolSize $synapseDedicatedPoolSize
	-synapseAADAdministratorGuid $synapseAADAdministratorGuid
	-purviewAccountName $purviewAccountName
	-tagsSynapseWorkspace $tagsSynapseWorkspace
	-tagsSynapseDedicatedPool $tagsSynapseDedicatedPool
	-tagsPurviewAccount $tagsPurviewAccount"

sudo pwsh -Command ./02-deployment-executor.ps1 \
-resourceGroupName $resourceGroupName \
-location $location \
-storageAccountName $storageAccountName \
-synapseWorkspaceName $synapseWorkspaceName \
-synapseAdminUsername $synapseAdminUsername \
-synapseAdminPassword $synapseAdminPassword \
-synapseDedicatedPoolName $synapseDedicatedPoolName \
-synapseDedicatedPoolSize $synapseDedicatedPoolSize \
-synapseAADAdministratorGuid $synapseAADAdministratorGuid \
-purviewAccountName $purviewAccountName \
-tagsSynapseWorkspace $tagsSynapseWorkspace \
-tagsSynapseDedicatedPool $tagsSynapseDedicatedPool \
-tagsPurviewAccount $tagsPurviewAccount

echo "Called PowerShell script."
echo "We are done successfully..."
