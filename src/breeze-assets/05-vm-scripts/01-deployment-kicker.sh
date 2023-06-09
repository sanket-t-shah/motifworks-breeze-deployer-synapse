#/bin/bash -e
echo $@
while getopts "s:u:p:" opt; do
    case $opt in
		s)
			synapse_workspace_name=$OPTARG
		;;
		u)
			synapse_workspace_username=$OPTARG
		;;
		p)
			synapse_workspace_password=$OPTARG
		;;
    esac
done
echo "................................................................................"
echo "Printing Environment Variables..."
echo "Synapse Workspace Name     : $synapse_workspace_name"
echo "Synapse Workspace Username : $synapse_workspace_username"
echo "Synapse Workspace Password : $synapse_workspace_password"
echo "Printed Environment Variables."
echo "................................................................................"
echo "Currently into Directory..."
echo `pwd`
echo "................................................................................"
echo "Printing Environment Variables..."
echo `env`
echo "Printed Environment Variables."
echo "................................................................................"
echo "Calling PowerShell script..."
echo "sudo pwsh -Command ./02-deployment-executor.ps1 -synapseWorkspaceName $synapse_workspace_name -synapseAdminUsername $synapse_workspace_username -synapseAdminPassword $synapse_workspace_password"
sudo pwsh -Command ./02-deployment-executor.ps1 -synapseWorkspaceName $synapse_workspace_name -synapseAdminUsername $synapse_workspace_username -synapseAdminPassword $synapse_workspace_password
echo "Called PowerShell script."
